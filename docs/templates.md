# Templates

Curlybars is able to evaluate templates written in a language that is essentially a subset of Handlebars. In the following section, we'll drill down in each aspect of the language, giving brief examples of how to use them.

## Basics

A Curlybars template is made up of **verbatim text** to be rendered as is, and **Curlybars expressions**. This implies that an empty template is also a valid template, and a template that contains only text is also a valid one, like the following.

```
<h1>Invoice</h1>

<p>Some details on the invoice</p>
```

To add templating logic to the previous example, you need Curlybars expressions which are enclosed by double curly brackets ( `{{` and `}}`):

```hbs
<h1>Invoice</h1>

<p>Some details on the invoice</p>

{{recipient.name}}
```

Note that nesting a pair of curlies within another pair is not valid syntax. For example, the following isn't allowed:

```
<h1>Invoice</h1>

<p>Some details on the invoice</p>

{{ {{ ... }} }}
```

## Comments

There are situations where having some notes in the template that do not leak into the rendered page might come in handy. For this purpose, Curlybars allows making comments putting an exclamation mark right after the opening curlies, without any space: `{{! ... }}`. You can use this syntax to add a code comment in the example:

```hbs
{{!
  This template shows details of an invoice
}}

<h1>Invoice</h1>

<p>Some details on the invoice</p>
```

This effect of discarding anything within the comments can actually come in handy while developing a template.

### Block comments

Unfortunately, the comment syntax described earlier isn't suitable for commenting out Curlybars code. To comment out Curlybars code, use the following syntax: `{{!-- ... --}}`. This kind of comment can also span on several lines.

```hbs
{{!
  This template aims to
  show details of an invoice
}}

<h1>Invoice</h1>

<p>Some details on the invoice</p>

{{!--
  I want to comment out the following code:

  {{ ... some Curlybars expressions }}

--}}
```

## Literals

Curlybars supports _literals_ for each of the three types of value: a **string**, a **boolean**, or a **number**.

For a string literal, you can use both single and double quotes, but you can't mix them. For example, `'this is a valid string'`, `"this is valid as well"`, but `"this is not valid'`.

A number can be any positive or negative integer: for instance, `123` is a valid positive number, `+123` represents the same value, `00123` is still valid, and `-123` is valid as well.

`true` and `false` are the boolean literals, and no other variation is allowed. In other words, `TRUE` and `FALSE` aren't interpreted as booleans.

Literals alone are also valid expressions:

```hbs
A string: {{ 'hello world' }}
A boolean: {{ true }}
A number: {{ 42 }}
```

## Paths

A **path** is a dot-based notation, used by the template to access a value nested deep down a root presenter, that will require navigating through several PORO presenters.

```hbs
<h1>Invoice</h1>

<p>Recipient: {{recipient.name}}</p>
```

The snippet above would cause the `recipient` method to be invoked on the root presenter. The `recipient` method would return a PORO presenter, that provides and has an instance method `name`, that would, in turn, be invoked and have its return value used to replace `{{recipient.name}}` in the template.

## Conditionals

Curlybars allows you to conditionally render part of the template. There are several ways to accomplish this, and one is using the `if` block. When using an `if` block, a valid expression must be given, such as a path or a literal, and the resulting value determines whether the content in the block is rendered or not. Look at the following snippet:

```hbs
<h1>Invoice</h1>

{{#if has_different_delivery_address}}
  <p>The delivery address is different from the billing address.</p>
{{/if}}

<p>Recipient: {{recipient.name}}</p>
```

Conversely, you might want to render a block when the condition is `false`. In that case, use an `unless` block. The syntax is straightforward:

```hbs
<h1>Invoice</h1>

{{#unless has_different_delivery_address}}
  <p>The delivery and billing addresses are the same.</p>
{{/unless}}

<p>Recipient: {{recipient.name}}</p>
```

To handle both of the conditions above, an `if-else` block can be used as well, as follows:

```hbs
<h1>Invoice</h1>

<p>
{{#if has_different_delivery_address}}
  The delivery address is different from the billing address.
{{else}}
  The delivery and billing addresses are the same.
{{/if}}
</p>

<p>Recipient: {{recipient.name}}</p>
```

Similarly, you can use the `unless-else` block to achieve the same effect:

```hbs
<h1>Invoice</h1>

<p>
{{#unless has_different_delivery_address}}
  The delivery and billing addresses are the same.
{{else}}
  The delivery address is different from the billing address.
{{/unless}}
</p>

<p>Recipient: {{recipient.name}}</p>
```

### How conditions are evaluated

A condition is usually based on a path, that will return a boolean value. Some paths, though, don't lead to a boolean value. A value that is not a boolean is interpreted as follow:

 * if the value is a number, then `0` is `false` and any other number is `true`;
 * if the value is a string, an empty string is `false` and any other string is `true`;
 * if the value is a collection of objects, an empty collection is `false` and any other collection is `true`;
 * if the value is `null`, the expression is `false`.

## Trimming white space

When Curlybars processes a template, it displays any verbatim text as is. That's good and works well most of the time. However, sometimes you need to have more control over the blank characters next to an expression. Take the following snippet as an example:

```hbs
<p class="{{#if highlighted}} highlight {{/if}}"> ... </p>
```

It renders the following HTML when highlighted is true:

```hbs
<p class=" highlight "> ... </p>
```

There's a leading and a trailing space around the word `highlight`. This, of course, works fine, but suppose you want to keep the spaces in the template without rendering them. In this case, you can use the tilde character (`~`).

Adding a tilde character in your opening or closing curly brackets will trim white space from the enclosed text. In other words, the following template:

```hbs
<p class="{{#if highlighted~}} highlight {{~/if}}"> ... </p>
```

would produce the following output:

```hbs
<p class="highlight"> ... </p>
```

The tilde character trims any blank character that doesn't have a graphical representation but affects spacing or split lines, such as newlines, tabs, carriage returns, line feeds, spaces, or tabs.

## Helpers

Accessing data, displaying it, and adding some conditional logic can be all you need in some templates. Still, you might like some added functionality: for example, you might want to display a localized string that changes according to the locale of the page requester, or you might want to truncate a long passage of text.

You can get this kind of functionality in templates with helpers. For example, you can implement and use a helper named `excerpt` in the Invoice page template to truncate strings. Suppose we need to show a truncated version of the item description. In this case, you can do this by modifying the template as follows:

```hbs
<h1>Invoice</h1>
<h2>{{excerpt item.description characters=50}}</h2>

...
```

The syntax to invoke a helper is `{{<helper> [<param> ...] [<key=value> ...]}}`. The only mandatory element is the name of the helper. Parameters and options vary depending on the implementation of helper.

## Narrowing the scope

Accessing data is pretty straightforward using dot notation, especially when the path to the information we need is not too long, like the case of `recipient.title`. In some circumstances, though, you might want to access several properties down a deep path, ending up repeating the prefix on each of those paths, like in the following snippet:

```hbs
<div>
  <p>Billing address: {{recipient.details.billing_address}}</p>
  <p>Delivery address: {{recipient.details.delivery_address}}</p>
  <p>Company name: {{recipient.details.company.name}}</p>
</div>
```

As you notice, all the paths are prefixed with `recipient.details`. The snippet above works just fine, but the long property paths make the code look a little cluttered. One way around the problem is to use the special `with` construct. `with` accepts one parameter that represents the prefix path to use in the code block associated with it, if the path is defined. The syntax is as follows:

```hbs
{{#with <prefix>}}
   ...
{{/with}}
```

Using the `with` construct, we can improve the example above:

```hbs
{{#with recipient.details}}
  <div>
    <p>Billing address: {{billing_address}}</p>
    <p>Delivery address: {{delivery_address}}</p>
    <p>Company name: {{company.name}}</p>
  </div>
{{/with}}
```

If we want to render a specific message whenever `recipient.details` is not defined, we can use an `else` branch, as follows:

```hbs
{{#with recipient.details}}
  <div>
    <p>Billing address: {{billing_address}}</p>
    <p>Delivery address: {{delivery_address}}</p>
    <p>Company name: {{company.name}}</p>
  </div>
{{else}}
  <p>Details are not available.</p>
{{/with}}
```

By prefixing the paths within the `with` block with the `../` notation repeatedly, we can jump back the same number of contexts. For instance, the following example will still work as expected, rendering `recipient.details.billing_address`:

```hbs
{{#with recipient.details}}
  <div>
    {{../details.billing_address}}
    ...
  </div>
{{/with}}
```

### Passing the root context to a helper

Use the `this` keyword to pass the current context to a helper. Suppose you have a `print_details` helper that accepts an invoice object as a parameter in order to display details about its recipient. You can use the `this` keyword as follows:

```hbs
{{#with recipient.details}}
  {{print_details this}}
{{/with}}
```

In the example above, `this` will be resolved to `recipient.details`.

## Accessing collection items

Paths can return a collection of objects. For example, the root presenter in the Invoice example might have a path `recipient.entries`, consisting of a collection of entries in the invoice.

To access the items in a collection you need to iterate over each one, and the `each` helper allows you to do exactly that:

```hbs
<ul>
{{#each recipient.entries}}
  <li>{{description}} -- ${{amount}}</li>
{{/each}}
</ul>
```

Each item in the collection contains data specific to one entry, such as its `{{description}}` and `{{amount}}`.

Like `with`, `each` changes the context in its block. This means that if you want to access the outer context, you can use the `../` notation.

You might want to render a message when a collection is empty. You can easily achieve this by using an `else` block, as follows:

```hbs
...
<ul>
{{#each recipient.entries}}
  <li>{{description}} -- ${{amount}}</li>
{{else}}
  There are no entries to show for this invoice.
{{/each}}
</ul>
```

### Length

Every collection has an implicit `length` property that returns the size of the collection. For example, if you want to display the number of entries, use the `length` property as follows:

```hbs
There are {{recipient.entries.length}} entries in this invoice.

<ul>
{{#each recipient.entries}}
  <li>{{description}} -- ${{amount}}</li>
{{/each}}
</ul>
```

## Analysis

Curlybars exposes a `.visit` method for traversing a template's parse tree. This can be used to analyze templates without actually rendering them.

For example, we may want to find out whether `{{description}}` is present in the following template:


```hbs
There are {{recipient.entries.length}} entries in this invoice.

<ul>
{{#each recipient.entries}}
  <li>{{description}} -- ${{amount}}</li>
{{/each}}
</ul>
```

We can define an AST visitor to test this:

```ruby
class DescriptionVisitor < Curlybars::Visitor
  def visit_path(node)
    if node.path == 'description'
      self.context = true
    end
    super
  end
end

source = <<-HBS
  There are {{recipient.entries.length}} entries in this invoice.

  <ul>
  {{#each recipient.entries}}
    <li>{{description}} -- ${{amount}}</li>
  {{/each}}
  </ul>
HBS

contains_description = Curlybars.visit(DescriptionVisitor.new(false), source)
contains_description == true # true
```

The spec for visitors includes more examples of the AST nodes that can be inspected this way.
