require 'curlybars/method_whitelist'

module Curlybars
  # A base class that can be subclassed by concrete presenters.
  #
  # A Curlybars presenter is responsible for delivering data to templates, in the
  # form of simple strings. Each public instance method on the presenter class
  # can be referenced in a template. When a template is evaluated with a
  # presenter, the referenced methods will be called with no arguments, and
  # the returned strings inserted in place of the components in the template.
  #
  # Note that strings that are not HTML safe will be escaped.
  #
  # A presenter is always instantiated with a context to which it delegates
  # unknown messages, usually an instance of ActionView::Base provided by
  # Rails. See Curlybars::TemplateHandler for a typical use.
  #
  # Examples
  #
  #   class BlogPresenter < Curlybars::Presenter
  #     presents :post
  #     allow_methods :title, :body, :author
  #
  #     def title
  #       @post.title
  #     end
  #
  #     def body
  #       markdown(@post.body)
  #     end
  #
  #     def author
  #       @post.author.full_name
  #     end
  #   end
  #
  #   presenter = BlogPresenter.new(context, post: post)
  #   presenter.author #=> "Jackie Chan"
  #
  class Presenter
    extend Curlybars::MethodWhitelist

    # Initializes the presenter with the given context and options.
    #
    # context - An ActionView::Base context.
    # options - A Hash of options given to the presenter.
    def initialize(context, options = {})
      @_context = context
      options.stringify_keys!

      self.class.presented_names.each do |name|
        value = options.fetch(name) do
          default_values.fetch(name) do
            block = default_blocks.fetch(name) do
              raise ArgumentError.new("required identifier `#{name}` missing")
            end

            instance_exec(name, &block)
          end
        end

        instance_variable_set("@#{name}", value)
      end
    end

    # Sets up the view.
    #
    # Override this method in your presenter in order to do setup before the
    # template is rendered. One use case is to call `content_for` in order
    # to inject content into other templates, e.g. a layout.
    #
    # Examples
    #
    #   class Posts::ShowPresenter < Curlybars::Presenter
    #     presents :post
    #
    #     def setup!
    #       content_for :page_title, @post.title
    #     end
    #   end
    #
    # Returns nothing.
    def setup!
      # Does nothing.
    end

    # The key that should be used to cache the view.
    #
    # Unless `#cache_key` returns nil, the result of rendering the template
    # that the presenter supports will be cached. The return value will be
    # part of the final cache key, along with a digest of the template itself.
    #
    # Any object can be used as a cache key, so long as it
    #
    # - is a String,
    # - responds to #cache_key itself, or
    # - is an Array or a Hash whose items themselves fit either of these
    #   criteria.
    #
    # Returns the cache key Object or nil if no caching should be performed.
    def cache_key
      nil
    end

    # The options that should be passed to the cache backend when caching the
    # view. The exact options may vary depending on the backend you're using.
    #
    # The most common option is `:expires_in`, which controls the duration of
    # time that the cached view should be considered fresh. Because it's so
    # common, you can set that option simply by defining `#cache_duration`.
    #
    # Note: if you set the `:expires_in` option through this method, the
    # `#cache_duration` value will be ignored.
    #
    # Returns a Hash.
    def cache_options
      {}
    end

    # The duration that the view should be cached for. Only relevant if
    # `#cache_key` returns a non nil value.
    #
    # If nil, the view will not have an expiration time set. See also
    # `#cache_options` for a more flexible way to set cache options.
    #
    # Examples
    #
    #   def cache_duration
    #     10.minutes
    #   end
    #
    # Returns the Fixnum duration of the cache item, in seconds, or nil if no
    #   duration should be set.
    def cache_duration
      nil
    end

    class << self
      # The name of the presenter class for a given view path.
      #
      # path - The String path of a view.
      #
      # Examples
      #
      #   Curlybars::TemplateHandler.presenter_name_for_path("foo/bar")
      #   #=> "Foo::BarPresenter"
      #
      # Returns the String name of the matching presenter class.
      def presenter_name_for_path(path)
        "#{path}_presenter".camelize
      end

      # Returns the presenter class for the given path.
      #
      # path - The String path of a template.
      #
      # Returns the Class or nil if the constant cannot be found.
      def presenter_for_path(path)
        name_space = Curlybars.configuration.presenters_namespace
        name_spaced_path = File.join(name_space, path)
        full_class_name = presenter_name_for_path(name_spaced_path)
        begin
          full_class_name.constantize
        rescue NameError
          nil
        end
      end

      # The set of view paths that the presenter depends on.
      #
      # Examples
      #
      #   class Posts::ShowPresenter < Curlybars::Presenter
      #     version 2
      #     depends_on 'posts/comment', 'posts/comment_form'
      #   end
      #
      #   Posts::ShowPresenter.dependencies
      #   #=> ['posts/comment', 'posts/comment_form']
      #
      # Returns a Set of String view paths.
      def dependencies
        # The base presenter doesn't have any dependencies.
        return SortedSet.new if self == Curlybars::Presenter

        @dependencies ||= SortedSet.new
        @dependencies.union(superclass.dependencies)
      end

      # Indicate that the presenter depends a list of other views.
      #
      # deps - A list of String view paths that the presenter depends on.
      #
      # Returns nothing.
      def depends_on(*dependencies)
        @dependencies ||= SortedSet.new
        @dependencies.merge(dependencies)
      end

      # Get or set the version of the presenter.
      #
      # version - The Integer version that should be set. If nil, no version
      #           is set.
      #
      # Returns the current Integer version of the presenter.
      def version(version = nil)
        @version = version if version.present?
        @version || 0
      end

      # The cache key for the presenter class. Includes all dependencies as
      # well.
      #
      # Returns a String cache key.
      def cache_key
        @cache_key ||= compute_cache_key
      end

      private

      def compute_cache_key
        dependency_cache_keys = dependencies.map do |path|
          presenter = presenter_for_path(path)
          if presenter.present?
            presenter.cache_key
          else
            path
          end
        end

        [name, version, dependency_cache_keys].flatten.join("/")
      end

      def presents(*args, **options, &block)
        if options.key?(:default) && block_given?
          raise ArgumentError, "Cannot provide both `default:` and block"
        end

        self.presented_names += args.map(&:to_s)

        if options.key?(:default)
          args.each do |arg|
            self.default_values = default_values.merge(arg.to_s => options[:default]).freeze
          end
        end

        return unless block_given?

        args.each do |arg|
          self.default_blocks = default_blocks.merge(arg.to_s => block).freeze
        end
      end

      def exposes_helper(*methods)
        methods.each do |method_name|
          define_method(method_name) do |*args|
            @_context.public_send(method_name, *args)
          end
        end
      end

      alias_method :exposes_helpers, :exposes_helper
    end

    private

    class_attribute :presented_names, :default_values, :default_blocks

    self.presented_names = [].freeze
    self.default_values = {}.freeze
    self.default_blocks = {}.freeze

    delegate :render, to: :@_context

    # Delegates private method calls to the current view context.
    #
    # The view context, an instance of ActionView::Base, is set by Rails.
    def method_missing(method, *args, &block)
      @_context.public_send(method, *args, &block)
    end

    # Tells ruby (and developers) what methods we can accept.
    def respond_to_missing?(method, include_private = false)
      @_context.respond_to?(method, false)
    end
  end
end
