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
          context = #{(context || DefaultContext.new).compile}.call
          helper = #{helper.compile}
          helper_position = rendering.position(#{helper.position.line_number},
            #{helper.position.line_offset})

          result = rendering.call(helper, #{helper.path.inspect}, helper_position, context, options) do
            # For consistency, the block must return empty
            # string in case it is yielded.
            ''
          end
          buffer.safe_concat(result.to_s)
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
