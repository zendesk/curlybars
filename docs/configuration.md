# Configuration

It is possible to change some aspects of how Curlybars works. By invoking `Curlybars.configure` and passing a block to it, you can access a configuration object that offers setter methods to customize specific aspects of Curlybars' behavior.

An example of how to configure the output size limit and the rendering timeout in Rails follows the line.

```ruby
# config/initializers/curlybars.rb

Curlybars.configure do |config|
  config.output_limit = 2.megabytes
  config.rendering_timeout = 5.seconds
end
```

## `presenters_namespace` (default `''`)

By default, Curlybars will follow the standard template name resolution, but you also can define a global namespace for all your presenters, by initializing Curlybars as follows:

```ruby
# config/initializers/curlybars.rb

Curlybars.configure do |config|
  config.presenters_namespace = 'Experimental'
end
```

In the invoice example, this will make Rails look up for `Experimental::Invoices::ShowPresenter` instead of `Invoices::ShowPresenter`.

## `nesting_limit` (default `10`)

Having several nested `with` or `each` blocks in a template causes the presenters stack to grow with it. By default, a template can nest at most `10` of these blocks, but by using the `nesting_limit` setter method it is possible to change this.

If a template has a nesting with more levels than it is allowed, then `Curlybars::Error::Render` will be raised.

This limit is checked at render time and only counts `with` and `each` blocks. It also caps how deeply nested the data serialized by the `json` helper can be. To limit how deeply any kind of block can be nested, see `parse_depth_limit`.

## `parse_depth_limit` (default `50`)

The parser rejects templates where blocks and subexpressions are nested more than `parse_depth_limit` levels deep, and raises `Curlybars::Error::Parse`. Unlike `nesting_limit`, it counts every kind of block (`if`, `unless`, `each`, `with`, and block helpers), and it applies when a template is compiled or validated rather than when it is rendered.

The limit keeps deeply nested templates from overflowing the stack while Ruby compiles them. That uses the machine stack, not the VM stack, so `RUBY_THREAD_VM_STACK_SIZE` makes no difference. With a 1 MB machine stack, about 72 nested `each` blocks raise `SystemStackError`, and each extra megabyte allows about 70 more levels. The size of the machine stack depends on where templates are compiled:

* Threads, as in threaded servers like Puma, get 1 MB by default. Raise it with `RUBY_THREAD_MACHINE_STACK_SIZE`.
* The main thread, which handles requests in single-threaded prefork servers like Unicorn, gets the process stack size limit (`ulimit -s`). `RUBY_THREAD_MACHINE_STACK_SIZE` doesn't apply to it. You can check the limit from Ruby with `Process.getrlimit(:STACK)`.
* Fibers get 512 KB by default (`RUBY_FIBER_MACHINE_STACK_SIZE`), and 37 nested `each` blocks are enough to overflow it.

Regardless of stack size, Ruby fails to parse the generated code at about 345 nested `each` blocks. These numbers were measured with Ruby 4.0.

If you raise `parse_depth_limit`, make sure the stack where templates are compiled is big enough for it:

```ruby
# In a threaded server, run with RUBY_THREAD_MACHINE_STACK_SIZE=2097152 (2 MB).
# In a prefork server, check that `ulimit -s` is at least 2 MB.
Curlybars.configure do |config|
  config.parse_depth_limit = 100
end
```

Every parse emits a `parse.curlybars` event through `ActiveSupport::Notifications`, including parses done by `Curlybars.validate`. `Curlybars.compile` caches its result, so it only emits the event on a cache miss. The payload has the template `identifier`, the `depth_limit` in effect, and `max_depth`, the deepest nesting of blocks and subexpressions in the template. When the parser rejects a template, the payload also has the error in `exception_object`. Subscribing to the event shows how close existing templates are to the limit:

```ruby
ActiveSupport::Notifications.subscribe("parse.curlybars") do |event|
  Rails.logger.info(event.payload.slice(:identifier, :max_depth).inspect)
end
```

## `traversing_limit` (default `10`)

Whenever a path is encountered, a path traversal is performed. In other words, the path is chunked up on the dots (`.`) and the resulting parts will be used to traverse the presenters, starting from the current context.

By default, a path can have at most 11 steps, but by using the `traversing_limit` setter method it is possible to change this. The limit counts the dots between the steps, so the maximum number of steps is `traversing_limit + 1`. Leading `../` segments don't count.

If a path with more dots than it is allowed is encountered, then `Curlybars::Error::Render` will be raised.

## `output_limit` (default `1.megabyte`)

It is possible to change the limit on the size of the rendered output. Having a reasonable limit can give better guarantees on the stability of the system, besides keeping under control the generated response traffic.

By default, the output limit is set to be `1.megabyte`, but by using the `output_limit` setter method it is possible to change this.

If the output limit is reached during a rendering, then `Curlybars::Error::Render` will be raised.

## `rendering_timeout` (default `10.seconds`)

Another constraint that is set in place is a timeout on the rendering time. A timeout of this kind can give better guarantees on the stability of the system.

By default, the timeout is set to be `10.seconds`, but by using the `rendering_timeout` setter method it is possible to change this.

If a rendering takes longer than the configured threshold, then `Curlybars::Error::Render` will be raised.

## `global_helpers_provider_classes` (default `[]`)

It is possible to register global helper provider classes via configuration. For more details about the meaning of global helpers, refer to [docs/helpers.md](helpers.md).

## `cache` (default `->(cache_key, &block) { block.call }`

To enable caching of PORO presenters with `{{#each}}`, set `cache` to a value that responds to `call` with one argument `cache_key` and a block. The callable is expected to return a cached value if the cache key is present, and otherwise call the block and store the result. To integrate with Rails, set this value to `Rails.cache.method(:fetch)`.

By default, caching is not enabled and will simply always invoke the block.

## `partial_provider_class` (default `nil`)

A class responsible for resolving runtime partials. When set, Curlybars will instantiate it with the view context and call `resolve_partial(name)` to look up partial template sources. The method should return a template source string or `nil` if the partial is not found.

```ruby
Curlybars.configure do |config|
  config.partial_provider_class = MyPartialProvider
end
```

If not set, runtime partial resolution is disabled and only presenter-based partials are available.

## `partial_nesting_limit` (default `3`)

Runtime-resolved partials can invoke other partials, creating nested rendering. To prevent infinite recursion, Curlybars limits the nesting depth. When the limit is reached at runtime, the partial renders as an empty string. If the limit is exceeded during validation, a `Curlybars::Error::Validate` with id `validate.partial_nesting_limit_reached` is raised instead.

```ruby
Curlybars.configure do |config|
  config.partial_nesting_limit = 3
end
```

**Security note:** Partial sources returned by `resolve_partial` are compiled through the full curlybars pipeline (lexer → parser → AST → code generation) before execution. This means they are subject to the same sandboxing as all other templates: method calls are gated by `allow_methods`, and safety limits (timeout, output size, nesting depth, traversal depth) apply equally.
