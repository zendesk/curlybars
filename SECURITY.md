# AI Agent Security Standard — Curlybars

This document defines mandatory security principles and restrictions for all AI coding assistants operating in this repository. All AI agents must follow these requirements without exception.

**Authority:** Derived from [Zendesk Minimum Baseline Security Standard](https://docs.google.com/document/d/17GZ9TpjKCt6WCdw3yxL44Ra_YscbOBVnVkUVGgx5Hz0/) and internal security policies.

---

## Core Security Mandate

Security is a first-class requirement. Every code suggestion must be evaluated against these guidelines. If a request would result in insecure code:

1. **Stop** and flag the security concern
2. **Explain** why it's problematic
3. **Propose** a secure alternative

AI-generated code requires human review before merging.

---

## Absolute Prohibitions

AI agents must **NEVER** do the following:

### Secrets & Credentials
- Hardcode secrets, credentials, API keys, tokens, or passwords in source code
- Store secrets in version control (`.env` files, config with real values)
- Log, print, or expose secret values
- Expose credentials in URLs, logs, or error messages

### Method Whitelist Bypass
- Generate code that circumvents the `allow_methods` whitelist on presenters
- Suggest `method_missing`, `send`, `public_send`, or `respond_to_missing?` overrides that would expose non-whitelisted methods to templates
- Weaken or remove `allows_method?` checks in `RenderingSupport`
- Add catch-all allowances (e.g., `allow_methods *instance_methods`) without explicit review

### Unsafe Template Evaluation
- Inject arbitrary Ruby into compiled template strings outside the controlled `Curlybars.compile` pipeline
- Use `eval`, `instance_eval`, or `class_eval` with user-supplied template content outside the compilation pipeline (note: `Security/Eval` is excluded for `spec/integration/**/*` only as a deliberate test choice)
- Disable the `rendering_timeout` or `output_limit` safety limits in production configuration

### Security Controls
- Disable or weaken security controls (`verify=False`, disabled auth, `ALLOW_ALL` CORS)
- Bypass authentication or authorization checks
- Disable certificate validation

### Dangerous Code Patterns
- Generate shell commands using raw string interpolation from user input
- Use deprecated algorithms (MD5, SHA-1, DES, RC4, ECB mode)

### Data Exposure
- Log sensitive data (PII, credentials, tokens, customer data)
- Expose stack traces or internal paths to end users
- Transmit sensitive data over unencrypted channels

---

## Required Security Patterns

### Presenter Method Whitelisting

```ruby
# Correct: Explicit whitelist — only these methods are accessible from templates
class InvoicePresenter < Curlybars::Presenter
  allow_methods :amount, :date, recipient: RecipientPresenter

  def amount
    @invoice.amount
  end
end
```

```ruby
# NEVER: Exposing all methods or bypassing the whitelist
class InvoicePresenter < Curlybars::Presenter
  allow_methods *instance_methods  # exposes everything
end
```

### Secret Management

```ruby
# Correct: Environment variables or secret manager
api_key = ENV.fetch("MY_SERVICE_API_KEY")
```

```ruby
# NEVER: Hardcoded secrets
api_key = "sk-abc123XYZ"
```

### Input Validation

```ruby
# Correct: Parameterized query
User.where(id: user_id)
```

```ruby
# NEVER: String interpolation in queries
User.where("id = #{user_id}")
```

### Logging

```ruby
# Correct: Structured logging without sensitive data
Rails.logger.info("Template compiled", path: template.virtual_path)
```

```ruby
# NEVER: Logging sensitive data
Rails.logger.debug("Presenter data: #{presenter.as_json}")  # may contain PII
```

---

## Security Requirements by Domain

### Template Compilation & Execution
- All template compilation must go through `Curlybars.compile` — do not bypass the pipeline
- Validate templates against a presenter's `dependency_tree` before deploying to production
- Set appropriate `rendering_timeout` and `output_limit` in Rails initializers to prevent resource exhaustion
- Never allow templates from untrusted sources to reference non-whitelisted paths

### Presenter Security
- Every public method accessible from a template must be explicitly declared via `allow_methods`
- Return types declared in `allow_methods` must accurately reflect the runtime types
- Do not use `Generic` as a return type unless the method genuinely needs to return variable types — it bypasses type-level validation

### Authentication & Authorization
- Use the approved authentication system for end-user authentication
- Apply principle of least privilege to presenter method exposure
- Log failed authorization checks in application code that uses Curlybars presenters

### Cryptography

| Use Case | Approved | Forbidden |
|----------|----------|-----------|
| Password hashing | bcrypt, Argon2, PBKDF2 | MD5, SHA-1, unsalted hashes |
| Integrity hashing | SHA-256, SHA-3 | MD5, SHA-1 |
| Symmetric encryption | AES-256-GCM | DES, 3DES, AES-ECB |
| TLS | TLS 1.2+ | SSLv2/3, TLS 1.0/1.1 |

### Error Handling
- Return typed `Curlybars::Error::*` instances — never expose raw Ruby exceptions or backtraces to end users
- Use the `id` field on errors for programmatic handling; use `message` for human-readable display only
- Do not include file paths or internal implementation details in error messages shown to template authors in production

---

## When to Stop and Escalate

Stop, explain the concern, and recommend involving Security if a task requires:

- Removing or weakening the `allow_methods` whitelist mechanism
- Adding template execution without validation against a presenter schema
- Disabling `rendering_timeout` or `output_limit` in a production context
- Bypassing or weakening security controls
- Exposing customer data or restricted information
- Using deprecated cryptographic algorithms
- Accessing production data without authorization
- Any change to the `Security/Eval` RuboCop exclusion scope

---

## Security Testing

When generating features, include:

- Tests verifying that non-whitelisted methods raise `Curlybars::Error::Validate` or `Curlybars::Error::Render`
- Tests confirming that `rendering_timeout` raises `Curlybars::Error::Render` with id `timeout`
- Negative test cases for invalid template paths and unauthorized method access
- Tests for presenter boundary enforcement (PORO presenters cannot expose unwhitelisted methods)

---

## Reporting Vulnerabilities

If you discover a security vulnerability in Curlybars, please report it to the maintainers at `vikings@zendesk.com` or via the [Zendesk Security Engagement process](https://techmenu.zende.sk/).

Do not open a public GitHub issue for security vulnerabilities.

---

## References

- [Minimum Baseline Security Standard](https://docs.google.com/document/d/17GZ9TpjKCt6WCdw3yxL44Ra_YscbOBVnVkUVGgx5Hz0/)
- [Cryptography Standards](https://techmenu.zende.sk/standards/cryptography-standards/)
- [Unified JWT Standard](https://techmenu.zende.sk/standards/unified-jwt/)

---

**Questions?** Reach out to @zendesk/vikings or file a ticket via the Security Engagement process.
