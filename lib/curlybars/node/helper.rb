require 'curlybars/error/validate'

module Curlybars
  module Node
    Helper = Struct.new(:helper, :context, :options, :position) do
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

      def validate(dependency_tree)
        [
          helper.validate(dependency_tree, check_type: :leaf),
          (context || DefaultContext.new).validate(dependency_tree),
          (options || []).map { |option| option.validate(dependency_tree) }
        ]
      end

      class DefaultContext
        def compile
          "->{}"
        end

        def validate(base_tree)
          []
        end
      end
    end
  end
end
