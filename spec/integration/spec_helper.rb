require 'integration/support/matcher'

module IntegrationTest
  module Helpers
    def beautify
      "bold#{yield}italic"
    end

    def form(path, opts)
      "beauty class:#{opts[:class]} foo:#{opts[:foo]} #{yield}"
    end

    def date(timestamp, opts)
      <<-HTML.strip_heredoc
        <time datetime="#{timestamp.strftime('%FT%H:%M:%SZ')}" class="#{opts[:class]}">
          #{timestamp.strftime('%B%e, %Y %H:%M')}
        </time>
      HTML
    end

    def asset(file_name)
      cdn_base_url = "http://cdn.example.com/"
      "#{cdn_base_url}#{file_name}"
    end

    def input(field, opts)
      type = opts.fetch(:title, 'text')
      <<-HTML.strip_heredoc
        <input name="#{field.name}" id="#{field.id}" type="#{type}" class="#{opts['class']}" value="#{field.value}">
      HTML
    end

    def partial
      'partial'
    end
  end

  class Presenter < Curlybars::Presenter
    include Helpers

    allow_methods :partial, :user, :new_comment_form, :valid, :visible, :return_true,
      :return_false, :beautify, :form, :date, :asset, :integer, :boolean, :me, :echo,
      :return_nil, :print_user_name, :this_method_yields

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

    def me
      self
    end

    def echo(context, options)
      "%s %s" % [context, options]
    end

    def print_user_name(context)
      yield context.user
    end

    def this_method_yields(context)
      yield
    end

    private

    def current_user
      User.new('Libo')
    end
  end
end
