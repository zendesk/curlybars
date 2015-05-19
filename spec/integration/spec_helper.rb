require 'integration/support/matcher'

module IntegrationTest
  module Helpers
    def beautify
      "bold#{yield}italic"
    end

    def form(context, options)
      "beauty class:#{options[:class]} foo:#{options[:foo]} #{yield}"
    end

    def date(context, options)
      <<-HTML.strip_heredoc
        <time datetime="#{context.strftime('%FT%H:%M:%SZ')}" class="#{options[:class]}">
          #{context.strftime('%B%e, %Y %H:%M')}
        </time>
      HTML
    end

    def asset(context)
      cdn_base_url = "http://cdn.example.com/"
      "#{cdn_base_url}#{context}"
    end

    def input(context, options)
      type = options.fetch(:title, 'text')
      <<-HTML.strip_heredoc
        <input name="#{context.name}" id="#{context.id}" type="#{type}" class="#{options['class']}" value="#{context.value}">
      HTML
    end

    def partial
      'partial'
    end
  end

  class Presenter < Curlybars::Presenter
    include Helpers

    allow_methods :print_current_context, :render_fn, :render_inverse, :user, :new_comment_form, :valid, :visible, :return_true,
      :return_false, :beautify, :form, :date, :asset, :integer, :boolean, :echo,
      :return_nil, :print_user_name, :this_method_yields, :this_method_yields, :context, :two_elements,
      :yield_custom_variable, :yield_custom_variable_and_custom_presenter,
      partial: :partial

    def user
      Shared::UserPresenter.new(current_user)
    end

    def new_comment_form
      Posts::NewPostFormPresenter.new
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

    def print_user_name(context)
      yield context.user
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

    def yield_custom_variable_and_custom_presenter(context)
      yield(context.user, custom: 'custom variable')
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

    private

    def current_user
      User.new('Libo')
    end
  end
end
