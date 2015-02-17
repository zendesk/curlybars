[![Build Status](https://magnum.travis-ci.com/zendesk/curlybars.svg?token=Fh9oDUV4oikq9kNCExpq&branch=master)](https://magnum.travis-ci.com/zendesk/curlybars)

Curlybars
=========

A fork of [Curly](https://github.com/zendesk/curly) that speaks Handlebars.

How to use Curlybars
--------------------

In order to use Curlybars for a view or partial, use the suffix `.hbs` instead of
`.erb`, e.g. `app/views/posts/_comment.html.hbs`.

Curlybars will look for a corresponding presenter class named `Posts::CommentPresenter`.

By convention, these are placed in `app/presenters/`, so in this case the presenter would reside in `app/presenters/posts/comment_presenter.rb`. Note that presenters for partials are not prepended with an underscore.

There are 2 kinds of presenter in Curlybars:

- `Curlybars::Presenter`
- PORO presenter

#### Curlybars::Presenter
They are like Curly Presenter (with some additions), they are associated to views and automatically looked up using the filename and the extension of the view file.
Furthermore they are responsible for the dynamic and static caching mechanism of Curly.
These are the methods available from Curly:
- `#setup!`
- `#cache_key`
- `#cache_options`
- `#cache_duration`
- `.version`
- `.depends_on`

#### PORO presenters
They are just Plain Old Ruby Object you expose in your hbs templates.
We are just asking you to include `Curlybars::MethodsWhitelisting` module. This will
implement a mechanism to declare which methods you want to expose into the view.
It's for your convenience only, you can also do it yourself as long as your class
defines a `.allows_method?` it should work.

Method Whitelisting
-------------------

Curlybars is designed to be used on the Help Center system at Zendesk.
We power many knowledge bases and communities that all require a unique look & feel.
We developed Curlybars to allow our customers freedom of implementing their own
layout while preserving the integrity of our system.

That's why Curlybars implements a paranoid declarative filter that defines which
methods are available in the presenters you are going to expose in the view.

```ruby
class PostPresenter < Object
  include Curlybars::MethodsWhitelisting
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
{{title}}
```

But not stuff like this:
```hbs
{{initialize 'foobar'}}

{{post}}
```

In the example above we might have inadvertently exposed `post` since it was
an `attr_reader` and not a method in the list of the public methods.
Same could happen if you include a module and forget that was defining a method.

Curlybars is paranoid about method leaking!

Both MainPresenter and SubPresenter implement the method whitelisting mechanism

Copyright and License
---------------------

Copyright (c) 2015 Zendesk Inc.
