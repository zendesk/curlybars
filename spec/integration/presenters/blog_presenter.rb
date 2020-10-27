require 'integration/presenters/baz_presenter'

module IntegrationTest
  class BlogPresenter < Curlybars::Presenter
    attr_reader :blog_builder

    allow_methods :a, :b, :baz, :blog

    def initialize(blog_builder)
      @blog_builder = blog_builder
    end

    def a
      "1"
    end

    def b
      "1"
    end

    def baz
      BazPresenter.new
    end

    def blog(arg1, arg2, arg3, options)
      blog_builder.call(arg1, arg2, arg3, options)
    end
  end
end
