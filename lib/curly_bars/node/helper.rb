require 'curly_bars/error/incorrect_ending_error'

module CurlyBars
  module Node
    class Helper
      attr_reader :helper, :context, :template, :helperclose, :opts

      def initialize(helper, context, template, helperclose, opts={})
        if helper != helperclose
          raise CurlyBars::Error::IncorrectEndingError,
            "block `#{helper}` cannot be closed by `#{helperclose}`"
        end

        @helper = helper
        @context = context
        @template = template
        @helperclose = helperclose
        @opts = opts
      end

      def compile
<<-RUBY
t = #{template.join("\n")}
buffer << contexts.last.public_send("#{helper}".to_sym, "#{context}", #{opts}) do
  t
end
RUBY
      end
    end
  end
end
