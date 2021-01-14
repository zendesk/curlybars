# Helpers

Sometimes you might have to do more than just rendering a template by only consuming the data encapsulated in the context. In some situations, for instance, you might want to excerpt a long passage of text.

For instance, in the invoice example we might want to expose a description of the invoice and show it in two different parts of the rendered page, one of these being an excerpted version and the other being the full version.

In theory, we could expose two distinct methods, one for each version of the descriptions, but a better approach would definitely be exposing only one method to provide just the full description and a helper capable of excerpting text. The excerpted version, of course, would be the result of the `excerpt` applied to the full description. The following snippet shows how the presenter would look like.

```ruby
# app/presenters/invoices/show_presenter.rb

class Invoices::ShowPresenter < Curlybars::Presenter
  presents :invoice

  allow_methods :amount, :date, :description
    recipient: RecipientPresenter,
    # allow `excerpt` and declare it as helper
    excerpt: :helper

  ...

  def description
    @invoice.description
  end

  # helper implementation
  def excerpt(context, options)
    max = options.fetch(:max, 120)
    context.to_s.truncate(max)
  end
end
```

Also, note how there is the `excerpt: :helper` keyword argument given to `.allow_methods`: this way, whenever a template is validated against this presenter, Curlybars will know the nature of `excerpt`.

With the presenter exposing the helper and the description, we can modify the template to make use of them as follows:

```hbs
{{! app/views/invoices/show.html.hbs }}

<p>Excerpted description: {{excerpt description max=50}}</p>
<p>Full description: {{description}}</p>
```

Although it's pretty straightforward to put helpers straight in a presenter, it can come in handy to move them into a module and include that module in the presenters where the helper are needed.

## Defining a helper

Implementing a helper is pretty straightforward, as it requires to follow a convention on the signature. Before diving into a thorough description of this convention, it makes sense to spend a few words on how a helper is invoked from a template.

The syntax to invoke a helper is `{{<helper> [<arg> ...] [<key=value> ...]}}`, and the only mandatory element is the name of the helper (`<helper>`). Immediately after the helper, optionally follows a list of arguments (`[<arg> ...]`) and then, still optionally, a list of keyword arguments (`[<key=value> ...]`). It's not possible to mix up the order of arguments and keyword arguments.

When Curlybars stumbles upon a helper call, will turn over the relevant presenter in order to figure out whether the helper is exposed or not. If the helper is allowed, then it will figure out how to invoke its method. The first thing to take into consideration, is that **the last parameter in the signature will always be used to pass the keyword arguments in a hash**. If other arguments are present, they will be assigned to the preceding parameters in the order in which they are specified.

Some examples will clarify the rules above. Let's suppose that we have the following code:

```hbs
{{helper 'argument' key1='value1'}}
```

In order to get those arguments as parameters of our helper, we must give to it a signature like the following:

```ruby
def helper(parameter, options)
  ...
end
```

If more argument are passed, they will be discarded, i.e.:

```hbs
{{helper 'argument' 'other' key1='value1'}}
```

```ruby
def helper(parameter, options)
  # 'argument' is assigned to the first parameter,
  # and the second parameter is a hash of this form: { key1: 'value1' }
end
```

On the contrary, if the helper has more parameters than arguments, then they will be given `nil` as value. In other words, the following template:

```hbs
{{helper 'argument' key1='value1'}}
```

```ruby
def helper(parameter, second_argument, options)
  # second_argument will be nil
end
```

As mentioned before, it's is okay to have no parameters at all:

```hbs
{{helper 'argument' key1='value1'}}
```

```ruby
def helper
  # will discard anything
end
```

But again, if we want to use at least one argument, we have to specify the options in the signature as well:

```hbs
{{helper 'argument'}}
```

```ruby
def helper(argument, options)
  # will use the only argument
end
```

Remember that you can always discard the options explicitly, using the `_` placeholder:

```hbs
{{helper 'argument'}}
```

```ruby
def helper(argument, _)
  # will discard options in a more readable way
end
```

Finally, if the helper has an invalid signature, `Curlybars::Error::Render` will be thrown at rendering time.

### Block helpers

Helpers can also have a block. By invoking `yield` in a helper method will cause the block to be rendered, and its content is returned to the helper in order to be consumed. This can come in handy in the case we want to implement a helper that produces a form, as follows:

```hbs
{{#form '/documents/new' class='red'}}
  <input type="text" name="body">
{{/form}}
```

```ruby
def form(action, options)
  klass = options[:class]

  "<form class='#{klass}' action='#{action}'>#{yield}</form>"
end
```

### Global Helpers

Regular helpers are only available in the scope of specific presenters. This works fine in case you don't want to make a helper available in any part of a template. Sometimes, though, you might want to have a helper available anywhere in the template, like in the case of the `excerpt` helper. A helper with this broad scope is referred to as **global helper**.

In order to get global helpers in place, simply define a PORO class and define the helpers as you'd do in a presenter. A class for the `excerpt` example would be the class following the line.

```ruby
class Helpers::GlobalHelper
  extend Curlybars::MethodWhitelist

  allow_methods :excerpt

  def excerpt(context, options)
    max = options.fetch(:max, 120)
    context.to_s.truncate(max)
  end
end
```

Note that it's not needed to specify that `excerpt` is a helper, (e.g., via `allow_methods excerpt: :helper`) as this class needs to be registered as a global helpers provider class as follows, and all of its allowed methods are assumed to be all helpers.

```ruby
Curlybars.configure do |config|
  config.global_helpers_provider_classes = [
    Helpers::GlobalHelper
  ]
end
```

### Collection Helpers

Collection helpers are standard helpers returning a specific kind of collections. It can be specified via `allow_methods` as:

```ruby
class ArticlePresenter
  extend Curlybars::MethodWhitelist

  allow_methods transform_articles: [:helper, [ArticlePresenter]]

  def transform_articles(articles, options)
    articles.map { |article| transform_article(article) }
  end
end
```

Collection helpers are useful when manipulating collections in `#each` statements via [subexpressions](./templates.md#subexpressions):

```hbs
{{#each (slice (transform_articles articles) 0 4)}}
  {{author.name}}
{{/each}}
```

### Generic Collection Helpers

Generic collection helpers are collection helpers that return a collection whose type is inferred from the first argument of the helper.
Hence, all generic collection helpers have a required argument.
It can be specified via `allow_methods` as:

```ruby
class Helpers::GlobalHelper
  extend Curlybars::MethodWhitelist

  allow_methods slice: [:helper, [Curlybars::Generic]]

  def slice(collection, start, length, _options)
    collection.slice(start, length)
  end
end
```

Unlike regular helpers, generic collection helpers *must* be specified as such in the global helper provider class.
These helpers are useful for implementing generic helpers for manipulating collections.
For example, displaying the title and excerpt of the first four articles written by a specific author:

```hbs
{{#each (slice (filter articles on="author.name" equals="Libo") 0 4)}}
  <section>
    <h3>{{title}}</h3>
    <div>{{excerpt body}}</div>
  </section>
{{/each}}
```

In the above example, both `slice` and `filter` will have a inferred return type of an `[ArticlePresenter]`.
