require 'integration/support/matcher'
require 'integration/presenters'

module IntegrationTest
  module Helpers
    def beautify
      "bold#{yield}italic"
    end

    def form(context, options)
      "beauty class:#{options[:class]} foo:#{options[:foo]} #{yield}"
    end

    def date(context, options)
      html = <<~HTML
        <time datetime="#{context.strftime('%FT%H:%M:%SZ')}" class="#{options[:class]}">
          #{context.strftime('%B%e, %Y %H:%M')}
        </time>
      HTML

      html.html_safe
    end

    def asset(context, _)
      cdn_base_url = "http://cdn.example.com/"
      "#{cdn_base_url}#{context}"
    end

    def input(context, options)
      type = options.fetch(:title, 'text')
      html = <<~HTML
        <input name="#{context.name}" id="#{context.id}" type="#{type}" class="#{options['class']}" value="#{context.value}">
      HTML

      html.html_safe
    end

    def partial
      'partial'
    end
  end

  class Presenter < Curlybars::Presenter
    include Helpers

    allow_methods :print_current_context, :render_fn, :render_inverse, :user, :new_comment_form, :valid, :visible, :return_true,
      :return_false, :beautify, :form, :date, :asset, :integer, :boolean, :echo, :just_yield, :print_args_and_options,
      :return_nil, :this_method_yields, :this_method_yields, :context, :two_elements,
      :yield_custom_variable, :print, :array_of_users, :'-a-path-', :article,
      articles: [Shared::ArticlePresenter],
      reverse_articles: [:helper, [Shared::ArticlePresenter]],
      partial: :partial

    def print(argument, _)
      argument.to_s
    end

    def array_of_users
      [user]
    end

    def article
      Shared::ArticlePresenter.new(Article.new)
    end

    def articles
      [
        Shared::ArticlePresenter.new(Article.new(id: 1, title: "A1", author: current_user)),
        Shared::ArticlePresenter.new(Article.new(id: 1, title: "A2", author: current_user)),
        Shared::ArticlePresenter.new(Article.new(id: 1, title: "B1", author: current_user)),
        Shared::ArticlePresenter.new(Article.new(id: 1, title: "B2", author: current_user))
      ]
    end

    def reverse_articles
      articles.reverse
    end

    def user
      Shared::UserPresenter.new(current_user)
    end

    def new_comment_form
      Posts::NewPostFormPresenter.new
    end

    def just_yield
      yield
    end

    def print_args_and_options(arg1, arg2, options)
      "#{arg1}, #{arg2}, key=#{options[:key]}"
    end

    def return_true
      true
    end

    def return_false
      false
    end

    def return_nil
      nil
    end

    def valid
      true
    end

    def visible
      true
    end

    def integer
      0
    end

    def boolean
      true
    end

    def context
      'root_context'
    end

    def echo(context, options)
      "%s %s" % [context, options]
    end

    def this_method_yields
      yield
    end

    def this_method_yields_nil
      yield nil
    end

    def yield_custom_variable
      yield(
        custom1: 'custom variable1',
        custom2: 'custom variable 2',
        cond: true)
    end

    def two_elements
      [user, user]
    end

    def render_inverse(_, options)
      options[:inverse].call
    end

    def render_fn(_, options)
      options[:fn].call
    end

    def print_current_context(_, options)
      options[:this].context
    end

    define_method('-a-path-') do
      'a path, whose name contains underscores'
    end

    private

    def current_user
      User.new(2, 'Libo')
    end
  end

  class GlobalHelperProvider
    extend Curlybars::MethodWhitelist
    include ActionView::Helpers::OutputSafetyHelper

    allow_methods :global_helper, :extract, :join,
      :foo, :bar, :equal, :concat, :dash, :input, :t, :calc,
      json: Curlybars::Generic,
      refl: Curlybars::Generic,
      slice: [Curlybars::Generic],
      translate: Curlybars::Generic

    def initialize(context = nil)
    end

    def calc(left, op, right, _)
      return unless left.is_a? Numeric
      return unless right.is_a? Numeric

      raise "Invalid operation: #{op}" unless %w[+ - * / ** > >= < <= ==].include?(op)

      eval <<-RUBY, binding, __FILE__, __LINE__ + 1
        #{left} #{op} #{right}
      RUBY
    end

    def slice(collection, start, length, _)
      collection[start, length]
    end

    def refl(object, _)
      object
    end

    def translate(object, locale, _)
      object.translate(locale)
    end

    def concat(left, right, _)
      "#{left}#{right}"
    end

    def dash(left, right, _)
      "#{left}-#{right}"
    end

    def foo(argument, _)
      "#{argument}#{argument}"
    end

    def bar(_, _)
      "LOL"
    end

    def equal(left, right, _)
      left == right
    end

    def input(_, options)
      label = options[:"aria-label"]
      placeholder = options[:placeholder]

      "<input aria-label=\"#{label}\" placeholder=\"#{placeholder}\" />"
    end

    def t(argument, _)
      argument.html_safe
    end

    def join(collection, options)
      collection
        .map(&options[:attribute].to_sym)
        .join(options[:separator])
    end

    def extract(item, options)
      item.public_send(options[:attribute])
    end

    def global_helper(argument, options)
      "#{argument} - option:#{options[:option]}"
    end

    def json(value, _)
      raw(value.to_json)
    end
  end
end
