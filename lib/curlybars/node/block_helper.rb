require 'curlybars/error/incorrect_ending_error'

module Curlybars
  module Node
    class BlockHelper
      attr_reader :helper, :context, :options, :template, :helperclose

      def initialize(helper, context, options, template, helperclose)
        if helper != helperclose
          raise Curlybars::Error::IncorrectEndingError,
            "block `#{helper}` cannot be closed by `#{helperclose}`"
        end

        @helper = helper
        @context = context
        @options = options || []
        @template = template
        @helperclose = helperclose
      end

      def compile
        compiled_options = options.map do |option|
          "options.merge!(#{option.compile})"
        end.join("\n")

        <<-RUBY
          options = ActiveSupport::HashWithIndifferentAccess.new
          #{compiled_options}
          ActiveSupport::SafeBuffer.new begin
              context = #{context.compile}.call
              helper = #{helper.compile}
              helper.call(*([context, options].first(helper.arity))) do
                contexts << context
                begin
                  #{template.compile}
                ensure
                  contexts.pop
                end
              end
            end
        RUBY
      end
    end
  end
end
