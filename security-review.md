# Security Review: Runtime Partial Resolution

## 1. `eval()` on dynamically-resolved source — MEDIUM-HIGH risk

**Location:** `rendering_support.rb:205`

The `render_partial` method calls `eval(compiled)` where `compiled` comes from `Curlybars.compile(source)` and `source` comes from `provider.resolve_partial(name)`. The security posture here depends entirely on **who controls the provider implementation**.

- The source goes through the full Curlybars lexer/parser pipeline, so arbitrary Ruby cannot be injected via the template string itself — only valid Handlebars constructs are accepted.
- **However**, if a provider were to return content sourced from user input (e.g., a database field editable by end users), that content gets compiled and eval'd. The Curlybars compilation does produce Ruby code fragments, and the lexer/parser is the security boundary.
- **Mitigant**: This is the same `eval` pattern used by the rest of the engine (root templates). No new attack surface *type* is introduced — but the *surface area* is expanded because partial sources can now come from runtime code rather than only from presenter methods.

**Recommendation**: Document clearly that `resolve_partial` providers must return trusted template sources only. Consider whether there's a need for an allowlist of partial names at the provider level.

## 2. Blanket `rescue StandardError` — MEDIUM risk

**Location:** `rendering_support.rb:206`

```ruby
rescue StandardError
  "".html_safe
```

This silently swallows **all** errors during partial rendering, including:
- `SecurityError`, `ArgumentError`, `TypeError`
- `Curlybars::Error::Render` (timeout errors, output-too-long errors)
- Any unexpected errors that might indicate a real problem

**Specific concern**: A timeout error raised by `check_timeout!` inside a nested partial will be caught here and silently return `""` instead of propagating. This means a malicious template could use deeply nested partials to consume CPU time — each level catches the timeout and returns empty, but the parent continues rendering. With `partial_nesting_limit=5`, an attacker gets 5 "free" timeout windows before the parent finally times out.

**Recommendation**: At minimum, re-raise `Curlybars::Error::Render` (especially timeout and output-too-long errors). Consider narrowing to something like:
```ruby
rescue Curlybars::Error::Render => e
  raise if e.id == 'timeout' || e.id == 'output_too_long'
  "".html_safe
rescue Curlybars::Error::Base
  "".html_safe
rescue StandardError
  "".html_safe
```

## 3. Thread-local state manipulation — LOW-MEDIUM risk

**Location:** `rendering_support.rb:191-197, 208-210`

The depth tracking and start-time propagation use `Thread.current` globals. The `ensure` block correctly restores previous values, but:

- In a threaded web server (Puma), if an exception occurs between setting and restoring these values in a way that bypasses the `ensure` (e.g., `Thread.kill`, `SystemExit`), the thread-local could be left in a corrupted state for subsequent requests on the same thread.
- The `rescue StandardError` on line 206 doesn't cover `Exception` subclasses like `SignalException` or `SystemStackError`, but the `ensure` block does run for those — so this is mostly safe.

**Mitigant**: The `ensure` block covers most cases. This is a minor concern.

## 4. `define_singleton_method` can override security methods — LOW-MEDIUM risk

**Location:** `partial_presenter.rb:7-8`

```ruby
@_data.each do |key, value|
  define_singleton_method(key) { value }
end
```

Option keys come from the template (`{{> card title="Hello"}}`), and the parser constrains key names to valid `KEY` tokens. However, if an option key collides with an existing Ruby method (`class`, `send`, `object_id`, `__send__`, `respond_to?`, etc.), `define_singleton_method` will **override** it on the presenter instance.

**Specific concern**: Overriding `allows_method?` or `allowed_methods` would break the whitelist system for that presenter. For example, `{{> card allows_method?="true"}}` would replace the security-critical method.

**Recommendation**: Add a denylist check in `PartialPresenter#initialize` to reject keys that match critical method names:
```ruby
RESERVED = %i[allows_method? allowed_methods class send __send__ object_id respond_to?].freeze
raise if RESERVED.include?(key)
```

## 5. Lenient validation bypass — LOW risk

**Location:** `node/partial.rb:24-27`

Validation was relaxed — any partial path is now accepted without checking the dependency tree. This is necessary for the feature but means:
- Static analysis tools that rely on `Curlybars.validate` can no longer catch typos in partial names
- A template referencing `{{> nonexistent}}` passes validation but silently renders nothing at runtime

This is a correctness concern more than a security one, but it weakens the safety net.

## 6. No output-limit enforcement on partial rendering — LOW risk

**Location:** `rendering_support.rb:199-205`

The compiled partial uses `eval(compiled)` which creates its own `buffer` (a `SafeBuffer`). The `SafeBuffer` enforces output limits per-buffer, but the partial's buffer is independent from the parent's buffer. The partial output is then `.to_s`'d and concatenated to the parent buffer (which does check the limit). So the global limit is enforced at concatenation time — this is fine.

## 7. Compilation cache poisoning — LOW risk

**Location:** `curlybars.rb:29-33`

```ruby
cache_key = ["Curlybars.compile", identifier, Digest::SHA256.hexdigest(source)]
```

The partial name is used as the identifier (`"partial:#{name}"`). If two different providers return different source strings for the same partial name at different times, the SHA256 of the source changes, so the cache key changes. This is safe.

However, the `ActiveSupport::Cache::MemoryStore` grows unboundedly. If an attacker can trigger many unique partial sources (e.g., via parameterized providers), the memory store grows without limit. This is a pre-existing concern, not new to these changes.

---

## Summary

| Finding | Severity | Actionable? |
|---|---|---|
| `rescue StandardError` swallows timeout/output-limit errors | **Medium-High** | Yes — re-raise critical errors |
| `define_singleton_method` can override security methods | **Low-Medium** | Yes — add reserved key denylist |
| `eval` on provider-sourced templates | **Medium** | Document trust requirements |
| Thread-local state edge cases | **Low** | Acceptable as-is |
| Lenient validation | **Low** | By design, document trade-off |

The **most actionable fix** is narrowing the `rescue StandardError` to not swallow timeout and output-limit errors. A crafted template with nested partials could currently use this to extend rendering time beyond the configured timeout.
