require 'curly_bars/error/incorrect_ending_error'

module CurlyBars
  module Node
    class Helper
      attr_reader :helper, :path, :template, :helperclose, :options

      def initialize(helper, context, template, helperclose, options = {})
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
          buffer << contexts.last.public_send("#{helper}".to_sym, "#{path}", #{options}) do
            #{template.compile}
          end
        RUBY
      end
    end
  end
end
