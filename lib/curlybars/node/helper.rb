module Curlybars
  module Node
    class Helper
      attr_reader :path, :context, :options

      class DefaultContext
        def compile
          "->{}"
        end
      end

      def initialize(path, context, options)
        @path = path
        @context = context || DefaultContext.new
        @options = options || []
      end

      def compile
        compiled_options = <<-RUBY
          options = ActiveSupport::HashWithIndifferentAccess.new
        RUBY

        compiled_options << options.map do |option|
          "options.merge!(#{option.compile})"
        end.join("\n")

        <<-RUBY
          #{compiled_options}
          ActiveSupport::SafeBuffer.new begin
            context = #{context.compile}.call
            helper = #{path.compile}
            helper.call(*([context, options].compact.first(helper.arity))) do
              raise "You cannot yield a block from within a helper. Use a block helper instead."
            end
          end
        RUBY
      end
    end
  end
end
