[![Build Status](https://magnum.travis-ci.com/zendesk/curlybars.svg?token=Fh9oDUV4oikq9kNCExpq&branch=master)](https://magnum.travis-ci.com/zendesk/curlybars)

Curlybars
=========

A fork of [Curly](https://github.com/zendesk/curly) that speaks Handlebars.

Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'curlybars'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install curlybars
```

How to use Curlybars
--------------------

In order to use Curlybars for a view or partial, use the suffix `.hbs` instead of
`.erb`, e.g. `app/views/posts/_comment.html.hbs`.

Curlybars will look for a corresponding presenter class named `Posts::CommentPresenter`.

By convention, these are placed in `app/presenters/`, so in this case the presenter would reside in `app/presenters/posts/comment_presenter.rb`. Note that presenters for partials are not prepended with an underscore.

There are 2 kinds of presenters in Curlybars:

- `Curlybars::Presenter`s
- P.O.R.O. presenters

#### The Compiler
- Uses RTLK in order to implement the lexer and the parser;
- AST nodes know how to compile themselves, and their children;
- Semantic checks at compile time:
 - check that opening and closing elements of helpers match.
- The target template embeds all the necessary presenter checks - runtime checking;
- Runtime checking is based on a whitelisting mechanism.
- Uses of scope gates to implements namespacing, e.g.:
 - {{#with context}} … {{/with}}
 - {{#each collection}} … {{/each}}
 - {{#block_helper context}} … {{/block_helper}}

#### The Language
- A path is an allowed and traversable chain of methods, like `movie.director`
- An expression is either a path, or a literal like a string, integer or boolean.
- Curlybars understands this Handlebars language subset:
 - {{helper [expression] [key=expression …]}}
 - {{#helper path [key=expression …]}} … {{/helper}}
 - {{#with path}} … {{/with}}
 - {{#each path}} … {{/each}}
 - {{#each path}} … {{else}} … {{/each}}
 - {{#if expression}} … {{/if}}
 - {{#if expression}} … {{else}} … {{/if}}
 - {{#unless expression}} … {{/unless}}
 - {{#unless expression}} … {{else}} … {{/unless}}
 - {{> partial}}
 - {{! … }}
 - {{!-- … --}}
 - {{~ … ~}}

#### Curlybars::Presenter
They are like `Curly::Presenter`s with some additions, and they are associated to views that are automatically looked up using the filename and the extension of the view file.
Furthermore they are responsible for the dynamic and static caching mechanism of Curly.
These are the methods available from Curly:
- `#setup!`
- `#cache_key`
- `#cache_options`
- `#cache_duration`
- `.version`
- `.depends_on`

#### P.O.R.O. presenters
They are just Plain Old Ruby Object you expose in your `hbs` templates. All you need is to extend `Curlybars::MethodWhitelist` module. This inclusion will implement a mechanism to declare which methods you want to expose into the view, integratind seamlessly with existing Object hierarchies.
It's for your convenience only, you can also do it yourself as long as your class
defines a `.allows_method?` it should work.

Helpers
-------

You can define custom helpers as normal method in your presenter.

Example:
```hbs
{{excerpt article.body max=400}}
```

```ruby
module HandlebarsHelpers
  extend Curlybars::MethodWhitelist
  allow_methods :excerpt

  def excerpt(context, options)
    max = options.fetch(:max, 120)
    context.to_s.truncate(max)
  end
end
```

It's a good practice to put your helpers into a module that you will include in different presenter, but you can also just put them as method of your presenter.

To implement the helper, some rules must be observed in order to formulate a correct signature.
First of all, the last argument in the signature will always be assigned by the options.
If other parameters are present, they will be assigned to the given arguments, in the order
in which they are specified.

It is ok to define a helper that does not have any parameter.

Some examples will clarify the rules above.

Let's suppose that we have the following code:

```hbs
{{helper 'argument' key1='value1'}}
```

In order to get those arguments as parameters of our helper, we must give to it
a signature like the following:

```ruby
def helper(argument, options)
 ...
end
```

if more argument are passed, they will be discarded, i.e.:

```hbs
{{helper 'argument' 'other' key1='value1'}}
```

```ruby
def helper(argument, options)
 # only the first argument is available
end
```

On the contrary, if the helper has more parameters that given arguments, then `nil`
will be bassed by Curlybars by default, i.e.:

```hbs
{{helper 'argument' key1='value1'}}
```

```ruby
def helper(argument, second_argument, options)
  # second_argument will be nil
end
```

It is okay to have no parameters at all:

```hbs
{{helper 'argument' key1='value1'}}
```

```ruby
def helper
  # will discard anything
end
```

But if we want to use at least one argument, we have to specify the options in the signature as well:

```hbs
{{helper 'argument'}}
```

```ruby
def helper(argument, options)
  # will use only argument
end
```

You can always discard the options explicitly, using the `_` placeholder:

```hbs
{{helper 'argument'}}
```

```ruby
def helper(argument, _)
  # will discard options in a more readable way
end
```

Note that there is an edge case with passing the options: if the method accepts only one

Note that if the helper has an invalid signature, an exception will be thrown at rendering time - `Curlybars::Error::Render`

All the rules above also applies to block helpers.

Block Helpers
-------------
You can also context helpers that takes a block.

Example:

```hbs
{{#form new_post class='red'}}
  <input type="text" name="body">
{{/form}}
```

```ruby
def form(context, options)
  klass = options[:class]
  action = context.action

  "<form class='#{klass}' action='#{action}'>#{yield}</form>"
end
```

Method Whitelisting
-------------------

Curlybars is designed to be used on the Help Center system at Zendesk.
We power many knowledge bases and communities that all require a unique look & feel.
We developed Curlybars to allow our customers freedom of implementing their own
layout while preserving the integrity of our system.

That's why Curlybars implements a paranoid declarative filter that defines which
methods are available in the presenters you are going to expose in the view.

```ruby
class PostPresenter
  extend Curlybars::MethodWhitelist
  allow_methods :title

  attr_reader :post

  def initialize(post)
    @post = post
  end

  def title
    post.original_title
  end
end
```

This will allow to use in the view:
```hbs
{{post.title}}
```

But not stuff like this:
```hbs
<!-- Call to #initialize on Post -->
{{post.initialize 'foobar'}}

<!-- Call to attribute reader post on Post hence caling directive the ActiveRecord -->
{{post.post.destroy}}
```

In the example above we might have inadvertently exposed `post` since it was
an `attr_reader` and not a method in the list of the public methods.
Same could happen if you include a module and forget that was defining a method.

Curlybars is paranoid about method leaking!

`Curlybars::Presenter` already extends `Curlybars::MethodWhitelist`.

Presenter namespacing
---------------------

By default Curlybars will follow the Curly's standard template name resolution.
Furthermore in Curlybars you can define a global namespace for all your
presenters associated with Handlebars `.hbs` views.

You just need to initialize Curlybars like this:

```ruby
# config/initializers/curlybars.rb
Curlybars.configure do |config|
  config.presenters_namespace = 'Experimental'
end
```

This will make the lookup system to search for presenters like:
```
Experimental::Articles::ShowPresenter
```

Exceptions
----------

Curlybars raises the following exceptions:
- `Curlybars::Error::Lex`
- `Curlybars::Error::Parse`
- `Curlybars::Error::Compile`
- `Curlybars::Error::Validate`
- `Curlybars::Error::Render`

Every exception object carries at least the following attributes that can be consumed:

 * id: a unique identifier for the exception
 * message: a generic error message that describes the encountered issue
 * position: a `Curlybars::Position` pointing to the exact location to the error. Meaningful for the `id`

### Lexer Errors

During the lexing phase, a `Curlybars::Error::Lex` exception can be raised.

Only one id is available for this exception: `lex`.

#### lex

Example - The following HBS raises this exception:
```hbs
{{! a string cannot be surrounded by two different types of quotes }}

{{t 'a string"}}
```

```hbs
{{! a path cannot be written using commas (only dots are valid) }}

{{first,second "a string"}}
```

### Parser Errors

During the parsing phase, a `Curlybars::Error::Parse` exception can be raised.

Only one id is available for this exception: `parse`.

#### parse

Example - The following HBS raises this exception:
```hbs
{{! #each can only iterate over a collection }}

{{#each 'a string'}}
{{/each}}
```

### Compiler Errors

During the compilation phase, a `Curlybars::Error::Compile` exception can be raised.

Only one id is available for this exception: `compile.closing_tag_mismatch`.

#### compile.closing_tag_mismatch

This exception is raised when a block helper is not closed properly. For instance:

```hbs
{{! a block helper can only be closed by a tag with the same name }}

{{#foo}}
{{/bar}}
```

### Validation Errors

During the validation phase, a `Curlybars::Error::Validate` exception can be raised.

The following descriptors are available:
- `validate.closing_tag_mismatch`
- `validate.not_a_partial`
- `validate.not_a_presenter`
- `validate.not_a_presenter_collection`
- `validate.not_a_leaf`
- `validate.not_a_helper`
- `validate.invalid_block_helper`
- `validate.unallowed_path`

#### validate.closing_tag_mismatch

This exception occurs when a block helper is not closed properly. This means
that each custom block helper must be closed by a tag with the same name. For instance:

```hbs
{{! a block helper can only be closed by a tag with the same name }}

{{#foo}}
  ...
{{/bar}}
```

#### validate.not_a_partial

This exception occurs when a path is called as a partial but it's not given
the allowed methods definition on the presenter. For instance:

```ruby
class NavigationPresenter
  allow_method menu: :partial

  def menu
    ...
  end
end
```

```hbs
{{! this will NOT raise the exception }}

{{> menu}}

{{! this will raise the exception }}

{{menu}}
```

#### validate.not_a_presenter

This exception occurs when a language construct that consumes a presenter is given a path that, according to its `allow_method` declaration, is not supposed to evaluate to a
presenter. For instance:

```ruby
class ArticlePresenter
  allow_methods :title, author: AuthorPresenter

  def title
    ...
  end

  def author
    ...
  end
end
```

```hbs
{{! this will NOT raise the exception }}

{{#with author}}
  ...
{{/with}}

{{! this will raise the exception }}

{{#with title}}
  ...
{{/with}}
```

#### validate.not_a_presenter_collection

This exception occurs when a language construct that consumes a presenter is given a path that, according to its `allow_method` declaration, is not supposed to evaluate to a
collection of presenters. For instance:

```ruby
class ArticlePresenter
  allow_methods :title, comments: [CommentPresenter]

  def title
    ...
  end

  def comments
    ...
  end
end
```

```hbs
{{! this will NOT raise the exception }}

{{#each comments}}
  ...
{{/each}}

{{! this will raise the exception }}

{{#each title}}
  ...
{{/each}}
```

#### validate.not_a_leaf

This exception occurs when a language construct that consumes a presenter is given a path that, according to its `allow_method` declaration, is not supposed to evaluate to a method that returns a terminal output. For instance:

```ruby
class ArticlePresenter
  allow_methods :link, comments: [CommentPresenter]

  def link(url)
    ...
  end

  def comments
    ...
  end
end
```

```hbs
{{! this will NOT raise the exception }}

{{link 'http://test.com/cat.jpg'}}

{{! this will raise the exception }}

{{comments 'http://test.com/cat.jpg'}}
```

#### validate.not_a_helper

This exception occurs when a path not marked as helper has been invoked. For instance:

```ruby
class ArticlePresenter
  allow_methods :not_a_helper, helper: :helper

  def not_a_helper
    ...
  end

  def helper
    ...
  end

end
```

```hbs
{{! this will NOT raise the exception }}

{{helper 'argument'}}

{{! this will raise the exception }}

{{not_a_helper 'argument'}}
```

#### validate.invalid_block_helper

This exception is raised when a block helper is not allowed either as a leaf or a presenter.

```ruby
class UserPresenter
  allow_methods block_helper: :other
end
```

```hbs
{{! this will raise the exception }}

{{#block_helper}} ... {{/block_helper}}
```

#### validate.invalid_signature

This exception is raised when invoking a method that is allowed as leaf - hence,
doesn't accept any arguments or options.

```ruby
class UserPresenter
  allow_methods :name

  def name
    ...
  end
end
```

```hbs
{{! this will raise the exception }}

{{name 'argument' option='value'}}
```

#### validate.unallowed_path

This exception occurs when a path is not allowed, given the allowed method definition
on the presenter. For instance:

```ruby
class UserPresenter
  allow_methods :name

  def name
    ...
  end
end
```

```hbs
{{! this will NOT raise the exception }}

{{ user.name }}

{{! this will raise the exception }}

{{ user.foo }}
```

Furthermore the exception exposed additional information in a `metadata` payload
with the following attributes (in the example above):

* path: "user.foo"
* step: :foo

### Rendering Errors

During the validation phase, a `Curlybars::Error::Render` exception can be raised.

The following descriptors are available:
- `render.context_is_not_a_presenter`
- `render.context_is_not_an_array_of_presenters`
- `render.invalid_helper_signature`
- `render.not_an_enumerable_or_hash`
- `render.unallowed_path`
- `render.traverse_too_deep`
- `render.output_too_long`
- `render.timeout`

#### render.context_is_not_a_presenter

This exception occurs when a language construct that consumes a presenter is given a path that is not supposed to evaluate to a
presenter. For instance:

```ruby
class ArticlePresenter
  allow_methods :title, author: AuthorPresenter

  def title
    ...
  end

  def author
    ...
  end
end
```

```hbs
{{! this will NOT raise the exception }}

{{#with author}}
  ...
{{/with}}

{{! this will raise the exception }}

{{#with title}}
  ...
{{/with}}
```

#### render.context_is_not_an_array_of_presenters

This exception occurs when a language construct that consumes a presenter is given a path that is not supposed to evaluate to a
collection of presenters. For instance:

```ruby
class ArticlePresenter
  allow_methods :title, comments: [CommentPresenter]

  def title
    ...
  end

  def comments
    ...
  end
end
```

```hbs
{{! this will NOT raise the exception }}

{{#each comments}}
  ...
{{/each}}

{{! this will raise the exception }}

{{#each title}}
  ...
{{/each}}
```

#### render.invalid_helper_signature

This exception occurs when an attempt to call a helper with an invalid signature is made. Refer to the related section for further details on what a correct helper signature looks like.

```ruby
class ArticlePresenter
  allow_methods :bad_signature_helper, :correct_signature_helper

  def bad_signature_helper(context:)
    ...
  end

  def correct_signature_helper(context)
    ...
  end
end
```

```hbs
{{! this will NOT raise the exception }}

{{correct_signature_helper 'context'}}

{{! this will raise the exception }}

{{bad_signature_helper 'context'}}
```

#### render.unallowed_path

This exception occurs when a path containing an unallowed subpath is used.

```ruby
class ArticlePresenter
  allow_methods :author

  def author
    ...
  end
end

class AuthorPresenter
  allow_methods :name

  def name
    ...
  end
end
```

```hbs
{{! this will NOT raise the exception }}

{{author.name}}

{{! this will raise the exception }}

{{author.surnames}}
```

Furthermore the exception exposed additional information in a `metadata` payload
with the following attribute (in the example above):

* meth: :surnames

#### render.traverse_too_deep

This exception occurs when in the template there are too many elements pushing
a context are found to be nested - (eg. `#with`). The maximum allowed depth
goes with the configuration parameter `nesting_limit`, that is set to 10 by default.

```hbs
{{! let's assume that nesting_limit is set to 2... }}

{{! this will NOT raise the exception }}

{{#with this}}
  {{#with this}}
  {{/with}}
{{/with}}

{{! this will raise the exception }}

{{#with this}}
  {{#with this}}
    {{#with this}}
    {{/with}}
  {{/with}}
{{/with}}

```

#### render.output_too_long

This exception occurs when the rendering process generates an output larger than
the value set for the `output_limit` configuration parameter.

#### render.timeout

This exception occurs when the rendering process is taking more than the value
set for the `rendering_timeout` configuration parameter.

Caching
-------
Curlybars tracks template dependencies and adds them to “its own” part of the cache key.
Curlybars doesn’t allow Rails to properly track template dependencies, and thus, we’re
disabling that feature. - thus, `{ skip_digest: true }` will be always merged
to the cache options provided by the presenters.

Contributing
------------

1. Fork the project
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Copyright and License
---------------------

Copyright (c) 2015 Zendesk Inc.
