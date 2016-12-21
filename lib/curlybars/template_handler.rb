require 'active_support'
require 'action_view'
require 'curlybars'
require 'curlybars/error/presenter/not_found'

module Curlybars
  class TemplateHandler
    class << self
      # Handles a Curlybars template, compiling it to Ruby code. The code will be
      # evaluated in the context of an ActionView::Base instance, having access
      # to a number of variables.
      #
      # template - The ActionView::Template template that should be compiled.
      #
      # Returns a String containing the Ruby code representing the template.
      def call(template)
        instrument(template) do
          compile(template)
        end
      end

      def cache_if_key_is_not_nil(context, presenter)
        key = presenter.cache_key
        if key.present?
          presenter_key = if presenter.class.respond_to?(:cache_key)
            presenter.class.cache_key
          end

          cache_options = presenter.cache_options || {}
          cache_options[:expires_in] ||= presenter.cache_duration

          # Curlybars doesn't allow Rails to handle the template digest.
          # So, we disable it.
          cache_options[:skip_digest] = true

          context.cache([key, presenter_key].compact, cache_options) do
            yield
          end
        else
          yield
        end
      end

      private

      def compile(template)
        # Template is empty, so there's no need to initialize a presenter.
        return %("") if template.source.empty?

        path = template.virtual_path
        presenter_class = Curlybars::Presenter.presenter_for_path(path)

        raise Curlybars::Error::Presenter::NotFound.new(path) if presenter_class.nil?

        # For security reason, we strip the encoding directive in order to avoid
        # potential issues when rendering the template in another character
        # encoding.
        safe_source = template.source.gsub(/\A#{ActionView::ENCODING_FLAG}/, '')

        source = Curlybars.compile(safe_source, template.identifier)

        <<-RUBY
          if local_assigns.empty?
            options = assigns
          else
            options = local_assigns
          end

          provider_classes = ::Curlybars.configuration.global_helpers_provider_classes
          global_helpers_providers = provider_classes.map { |klass| klass.new(self) }

          presenter = ::#{presenter_class}.new(self, options)
          presenter.setup!

          @output_buffer = output_buffer || ::ActiveSupport::SafeBuffer.new

          ::Curlybars::TemplateHandler.cache_if_key_is_not_nil(self, presenter) do
            safe_concat begin
              #{source}
            end
          end

          @output_buffer
        RUBY
      end

      def instrument(template, &block)
        payload = { path: template.virtual_path }
        ActiveSupport::Notifications.instrument("compile.curlybars", payload, &block)
      end
    end
  end
end
