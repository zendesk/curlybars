require 'active_support'
require 'action_view'
require 'curlybars'
require 'curly/template_handler'
require 'curly/presenter_not_found'

class Curlybars::TemplateHandler < Curly::TemplateHandler
  class << self
    private

    def compile(template)
      # Template is empty, so there's no need to initialize a presenter.
      return %("") if template.source.empty?

      path = template.virtual_path
      presenter_class = Curlybars::Presenter.presenter_for_path(path)

      raise Curly::PresenterNotFound.new(path) if presenter_class.nil?

      source = Curlybars.compile(template.source, template.identifier)

      code = <<-RUBY
      require 'timeout'

      if local_assigns.empty?
        options = assigns
      else
        options = local_assigns
      end

      presenter = ::#{presenter_class}.new(self, options)
      presenter.setup!

      @output_buffer = output_buffer || ActiveSupport::SafeBuffer.new

      Curly::TemplateHandler.cache_if_key_is_not_nil(self, presenter) do
        begin
          Timeout::timeout(Curlybars.configuration.rendering_timeout) do
            safe_concat begin
              #{source}
            end
          end
        rescue Timeout::Error
          message = "Rendering took too long (> %s seconds)" % Curlybars.configuration.rendering_timeout
          raise Curlybars::Error::Render.new('timeout', message, nil)
        end
      end

      @output_buffer

      RUBY

      code
    end

    def instrument(template, &block)
      payload = { path: template.virtual_path }
      ActiveSupport::Notifications.instrument("compile.curlybars", payload, &block)
    end
  end
end
