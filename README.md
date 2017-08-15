[![Build Status](https://magnum.travis-ci.com/zendesk/curlybars.svg?token=Fh9oDUV4oikq9kNCExpq&branch=master)](https://magnum.travis-ci.com/zendesk/curlybars)

# Curlybars

Curlybars is a Ruby implementation of a subset of Handlebars, where getting the context for rendering the template is based on the presenter approach taken in [Curly](https://github.com/zendesk/curly).

## Table of Contents
1. [Overview](#overview)
1. [Getting started](#getting-started)
1. [Configuration](#configuration)
1. [Contributing](#contributing)
1. [Maintainers](#maintainers)
1. [Copyright and License](#copyright-and-license)

## Getting started

Curlybars is a templating engine for Ruby, and it integrates with Rails out of the box. In order to use it with Rails, at least a **root presenter** and a **template** must be provided for each view that is meant to be rendered via Curlybars.

A template is, in fact, a Handlebars template and must use the `.hbs` instead of `.erb` extension, such as `app/views/invoice/details.html.hbs`.

A root presenter is a class providing the root context used to evaluate a given template. In other words, if the template contains the string `{{amount}}`, then the root presenter must provide an instance method named `amount`.

Whenever a deeper reference like path is encountered in a template, like `{{recipient.name}}`, the root presenter is expected to have a method named `recipient`, returning an instance of a Poor Old Ruby Object presenter (a non-root presenter) with a method called `name`.

More on what has been introduced here will be explained in details later sections.

## Getting started

To provide your Rails app with Curlybars, simply add the following line in your `Gemfile`, possibly narrowing down the version you want to depend on:

```ruby
gem 'curlybars'
```

And then simply run `bundle install`. At this point, we can start to create a trivial example, that shows how to get started with rendering a page.

For starters, let's create a couple of classes, `Invoice` and `Recipient`, that hold part of the information that would be in an invoice.

```ruby
# app/models/invoice.rb

class Invoice
  def initialize(amount:, recipient:)
    @amount = amount
    @recipient = recipient
  end

  def amount
    @amount
  end

  def recipient
    @recipient
  end
end
```

```ruby
# app/models/recipient.rb

class Recipient
  def initialize(name:)
    @name = name
  end

  def name
    @name
  end
end
```

Then, let's add a controller to implement the `show` action for invoices, as follows.

```ruby
# app/controllers/invoices_controller.rb

class InvoicesController < ApplicationController
  def show
    recipient = Recipient.new(name: "John Venturini")
    @invoice = Invoice.new(amount: 100, recipient: recipient)
  end
end
```

If we provide a Handlebars template at `app/views/invoices/show.html.hbs`, then by Rails convention it will be used. Let's get the following snippet to be the content of the template:

```hbs
{{! app/views/invoices/show.html.hbs }}

<h1>Amount #{{amount}} (issued on {{date}})</h1>
<h2>To: {{recipient.name}}</h2>
```

As you can see, there are regular Handlebars paths within curlies (`{{` and `}}`). In a situation where we'd use Handlebars we would have to provide a context as well, so that for instance `recipient.name` can be resolved to an actual value to replace `{{recipient.name}}`. Curlybars provides a context in a similar way [Curly](https://github.com/zendesk/curly) does: namely, using presenters like the following one.

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

Presenters of this kind, extending `Curlybars::Presenter`, are referred to as root presenters. Note that root presenters will be looked up by Rails in a similar way views are. All the presenters have to reside in the `app/presenters` folder, within a subfolder named after the model they are used for (in this case, `invoices`) and have a name that follows the `<action>_presenter.rb` pattern. The presenter in the example above, for instance, would be looked up at `app/presenters/invoices/show_presenter.rb`.

When extending `Curlybars::Presenter`, we get access to a convenience method `.allow_methods` to explicitly whitelist and describe whan can be done with this presenter. In the example above, we are declaring that from the template we can access the `amount` and `date` fields using curlies (namely, `{{amount}}` and `{{date}}`) and that an extra presenter can be accessed via `recipient` and traversed using the path syntax.

`RecipientPresenter` would be a PORO presenter, and as such we only need to `extend Curlybars::MethodWhitelist` so that `allow_methods` can be used.

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

On a side note, describing the accessible data via `.allow_methods` also allows Curlybars to perform templates validation: in other words, Curlybars is able to tell wether a template is going to be rendered successfully or not, by simply looking at the template itself and at what has been declared accessible.

At this point, running the Rails app and going to the page configured to show the page of this example, would render the Handlebars template as expected, according to what the presenter will provide.

## Configuration

Curlybars offers configuration options aimed to fine-tune runtime constraints, useful for when you need to make sure a page rendering is aborted when the size reaches a certain limit, or when it takes too long.

Getting some configuration in Rails is as simple as adding an initializer (e.g., `config/initializers/curlybars.rb`) having a similar content like the following.

```ruby
Curlybars.configure do |config|
  config.output_limit = 2.megabytes
  config.rendering_timeout = 5.seconds
end
```

## Contributing

Contributing to Curlybars is fairly easy, as long as the following steps are followed:

1. Fork the project
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request
1. Mention one or more of the maintainers to get the Pull Request approved and merged

## Maintainers

This is the list of Curlybars maintainers, in no particular order:

* Liborio Cannici ([@libo](https://github.com/libo))
* Ilkka Oksanen ([@ilkkao](https://github.com/ilkkao))
* Mauro Codella ([@codella](https://github.com/codella))

## Copyright and License

Copyright (c) 2017 Zendesk Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
