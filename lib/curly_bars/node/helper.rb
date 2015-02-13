require 'curly_bars/error/incorrect_ending_error'

module CurlyBars
  module Node
    class Helper
      attr_reader :helper, :path, :template, :helperclose, :options

      def initialize(helper, path, template, helperclose, options = {})
        if helper != helperclose
          raise CurlyBars::Error::IncorrectEndingError,
            "block `#{helper}` cannot be closed by `#{helperclose}`"
        end

        @helper = helper
        @path = path
        @template = template
        @helperclose = helperclose
        @options = options
      end

      def compile
        <<-RUBY
          buffers << buffer
          options = ActiveSupport::HashWithIndifferentAccess.new(#{options})
          buffer << contexts.last.public_send("#{helper}".to_sym, "#{path}", options) do
            contexts << contexts.last.public_send("#{path}".to_sym)
            buffer = ActiveSupport::SafeBuffer.new
            #{template.compile}
            contexts.pop
            buffer
          end
          buffer = buffers.pop
        RUBY
      end
    end
  end
end
