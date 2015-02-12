require 'curly_bars/error/incorrect_ending_error'

module CurlyBars
  module Node
    class Helper
      attr_reader :helper, :context, :template, :helperclose

      def initialize(helper, context, template, helperclose)
        if helper != helperclose
          raise CurlyBars::Error::IncorrectEndingError,
            "block `#{helper}` cannot be closed by `#{helperclose}`"
        end

        @helper = helper
        @context = context
        @template = template
        @helperclose = helperclose
      end

      def compile
        t = template.join("\n")
<<-RUBY
buffer << contexts.last.public_send("#{helper}".to_sym, "#{context}")
RUBY
      end
    end
  end
end
