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

Having several nested `with` or `each` blocks in a template causes the presenters stack to grow with it. The default nesting level is set to `10`, but by using the `nesting_limit` setter method it is possible to change this.

If a template has a nesting with more levels than it is allowed, then `Curlybars::Error::Render` will be raised.

## `traversing_limit` (default `10`)

Whenever a path is encountered, a path traversal is performed. In other words, the path is chunked up on the dots (`.`) and the resulting parts will be used to traverse the presenters, starting from the current context.

By default, the maximum number of steps in a path is set to be `10`, but by using the `traversing_limit` setter method it is possible to change this.

If a path with more steps than it is allowed is encountered, then `Curlybars::Error::Render` will be raised.

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
