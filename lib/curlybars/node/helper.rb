module Curlybars
  module Node
    class Helper
      attr_reader :helper, :context, :options

      class DefaultContext
        def compile
          "->{}"
        end
      end

      def initialize(helper, context, options)
        @helper = helper
        @context = context || DefaultContext.new
        @options = options || []
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
            helper.call(*([context, options].compact.first(helper.arity))) do
              raise "You cannot yield a block from within a helper. Use a block helper instead."
            end
          end
        RUBY
      end
    end
  end
end
