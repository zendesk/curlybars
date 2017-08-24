# Errors

In different situations, Curlybars might raise an error. There are different classes of error, so that the nature of the issue is well represented.

Regardless of its type, an error object carries at least the following attributes:

 * `id`: a unique string identifier for the exception
 * `message`: a generic error message that describes the encountered issue
 * `position`: a `Curlybars::Position` pointing to the exact location to the error

A description of all the possible errors that can arise is given in the sections that follow.

## Lexer Errors

During the lexing phase, a `Curlybars::Error::Lex` exception can be raised.

### Id `lex`

The following snippets of code raise this exception:

```hbs
{{! a string cannot be surrounded by two different types of quotes }}

{{t 'a string"}}
```

```hbs
{{! a path cannot be written using commas (only dots are valid) }}

{{first,second}}
```

## Parser Errors

During the parsing phase, a `Curlybars::Error::Parse` exception can be raised.

### Id `parse`

The following snippets of code raise this exception:

```hbs
{{! #each can only iterate over a collection }}

{{#each 'a string'}}
{{/each}}
```

## Compiler Errors

During the compilation phase, a `Curlybars::Error::Compile` exception can be raised.

Only one id is available for this exception: `compile.closing_tag_mismatch`.

### Id `compile.closing_tag_mismatch`

This exception is raised when a block helper is not closed properly, as in the following exception:

```hbs
{{! a block helper can only be closed by a tag with the same name }}

{{#foo}}
{{/bar}}
```

## Validation Errors

During the validation phase, a `Curlybars::Error::Validate` exception can be raised.

### Id `alidate.closing_tag_mismatch`

This exception occurs when a block helper is not closed properly. This means
that each custom block helper must be closed by a tag with the same name. For instance:

```hbs
{{! a block helper can only be closed by a tag with the same name }}

{{#foo}}
  ...
{{/bar}}
```

### Id `validate.not_a_partial`

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

### Id `validate.not_a_presenter`

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

### Id `validate.not_a_presenter_collection`

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

### Id `validate.not_a_leaf`

This exception occurs when a language construct that consumes a presenter is given a path that, according to its `allow_method` declaration, is not supposed to evaluate to a method that returns a terminal output. For instance:

```ruby
class InvoicePresenter
  allow_methods link: :helper, entries: [EntryPresenter]

  def link(url)
    ...
  end

  def entries
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

### Id `validate.not_a_helper`

This exception occurs when a path not marked as helper has been invoked. For instance:

```ruby
class InvoicePresenter
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

### Id `validate.invalid_block_helper`

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

### Id `validate.invalid_signature`

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

### Id `validate.unallowed_path`

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

## Rendering Errors

During the validation phase, a `Curlybars::Error::Render` exception can be raised.

### render.context_is_not_a_presenter

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

### render.context_is_not_an_array_of_presenters

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

### render.invalid_helper_signature

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

### render.unallowed_path

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

### render.traverse_too_deep

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

### render.output_too_long

This exception occurs when the rendering process generates an output larger than
the value set for the `output_limit` configuration parameter.

### render.timeout

This exception occurs when the rendering process is taking more than the value
set for the `rendering_timeout` configuration parameter.
