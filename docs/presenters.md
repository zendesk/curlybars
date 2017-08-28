# Presenters

In the Handlebars world, a template is evaluated against a context: that is, an object that provides data the template can consume in order to render the final document.

The equivalent of a Handlebars context in Curlybars is a `presenter`, with some differences. Curlybars presenters are divided into two categories: **root presenters** and **PORO presenters**.

Root presenters provide the root level of the context. A comparison with the Handlebars context would be that the root presenter provides the values to the root keys of the context. In other words, assume the following object is a Handlebar context.

```js
{
  amount: "100",
  date: "August 22th, 2017",
  recipient: {
    name: "John Venturini"
  }
}
```

In this case, a root presenter would provide values for the keys `amount`, `date` and `recipient` only.

In order to provide the rest of the context, a root presenter can return a PORO presenter. In the example above, a PORO presenter would be returned by the root presenter, as the template accesses the `recipient` key.

The distinction between this two kind of presenter is made as the root presenter, being the entry point to the context, has also the responsibility to tell whether a cached version of the rendered output can be used or not. Moreover, a root presenter determines what instance variables set by the controller can be actually accessed.

In the following sections, an in-depth description of both kinds of presenters will be given.

## Methods whitelisting

Both kinds of presenter need to whitelist which methods can be accessed from the template. If all you are interested into is rendering templates, accepting that errors can arise at rendering time, then the only instance method you really need to implement is `#allows_method?`. This method accepts a symbol representing a method name as an argument, and will return a boolean according to whether that method is actually allowed to be used by the template or not. In other words, this allows to whitelist methods, that is typically considered a good practice in order to avoid accidental method exposure.

As an alternative, you would `extend Curlybars::MethodWhitelist`, that gives you access to the class method `.allow_methods` that permits to declaratively specify what methods are allowed, and what the return type is. On the other hand, root presenters need to extend `Curlybars::Presenter`, which will automatically mix in `#allow_methods`.

`#allow_methods` accepts a list of keyword arguments, where the name of the argument represents the name of the method being allowed, and the value represents its nature. As an example, `allow_methods name: nil` will permit the method `#name`, stating that it returns a literal. All the possible values for the keywords are:

 * `nil`, to state that the method returns a literal;
 * `POROClass`, to state that the method returns a `POROClass` instance, expected to be a PORO presenter;
 * `[POROClass]`, to state that the method returns an array of `POROClass` instances.

Also, prior to the keywords list is is possible to specify a list of symbols, to specify which methods return a literal. In other words, `allow_methods :name, :surname` is equivalent to `allow_methods name: nil, surname: nil`.

## Root presenters

Root presenters are the first presenters Curlybars will look for, as a view is being rendered. Presenters of this kind have to extend `Curlybars::Presenter` and will be looked up by Rails in a similar way views are.

In general, all the presenters have to reside in the `app/presenters` folder, and root presenters have to be within a subfolder named after the pluralized model name they are used for and have a file name that follows the `<action>_presenter.rb` pattern (eg. `app/presenters/invoices/show_presenter.rb`).

An example of root presenter follows the line.

```ruby
# app/presenters/invoices/show_presenter.rb

class Invoices::ShowPresenter < Curlybars::Presenter
  presents :invoice

  allow_methods :amount, :date,
    recipient: RecipientPresenter

  def amount
    @invoice.amount
  end

  def date
    @invoice.created_at.to_formatted_s(:short)
  end

  def recipient
    RecipientPresenter.new(@invoice.recipient)
  end
end
```

Root presenters allow fine-tuning for caching rendered templates, [exactly the same way as it is implemented in Curly](https://github.com/zendesk/curly#caching).

As Curlybars doesn’t allow Rails to track template dependencies based on their digest, `{ skip_digest: true }` will be always merged to the cache options provided by the presenters.

## PORO presenters

PORO presenters are no more than Plain Old Ruby Objects. They can have methods that return either a literal or another PORO presenter.

```ruby
# app/presenters/recipient_presenter.rb

class RecipientPresenter
  extend Curlybars::MethodWhitelist

  allow_methods :name

  def initialize(recipient)
    @recipient = recipient
  end

  def name
    @recipient.name
  end
end
```

## Validation

Rendering a template might incur into errors of various kinds. For instance, having a template with a malformed string (eg. `'string"` with different quotes) causes the lexer to raise an instance of `Curlybars::Error::Lex`, or an unallowed path would raise an instance of `Curlybars::Error::Render`.

For many cases, accepting that those errors might arise is fine, but in other circumstances, though, it could be better if we can know what issues our templates have.

Curlybars is shipped with a validation feature, accessible by `Curlybars.validate` or `Curlybars.valid?`. Both of those methods accept a template content, in the form of a string, and a root presenter class the template will be rendered with.

If you are simply interested to know whether there will be errors upon rendering, then `Curlybars.valid?` can answer that question, but if you want to know what will exactly go wrong during compilation, then `Curlybars.validate` is what you're looking for.

`Curlybars.validate` will return an array of `Curlybars::Error::Validate` errors, so getting an empty array simply means that no errors have been encountered. A comprehensive list of all the possible validation errors can be found in [docs/errors.md](errors.md).
