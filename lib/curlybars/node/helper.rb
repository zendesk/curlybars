module Curlybars
  module Node
    Helper = Struct.new(:helper, :context, :options) do
      def compile
        compiled_options = (options || []).map do |option|
          "options.merge!(#{option.compile})"
        end.join("\n")

        <<-RUBY
          options = ActiveSupport::HashWithIndifferentAccess.new
          #{compiled_options}
          ActiveSupport::SafeBuffer.new begin
            context = #{(context || DefaultContext.new).compile}.call
            helper = #{helper.compile}
            helper.call(*([context, options].compact.first(helper.arity))) do
              raise "You cannot yield a block from within a helper. Use a block helper instead."
            end
          end
        RUBY
      end

      class DefaultContext
        def compile
          "->{}"
        end
      end
    end
  end
end
