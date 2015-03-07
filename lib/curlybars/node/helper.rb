require 'curlybars/error/validate'

module Curlybars
  module Node
    Helper = Struct.new(:helper, :context, :options, :position) do
      def compile
        compiled_options = options.map do |option|
          "options.merge!(#{option.compile})"
        end.join("\n")

        <<-RUBY
          options = ActiveSupport::HashWithIndifferentAccess.new
          #{compiled_options}
          context = #{context.compile}.call
          helper = #{helper.compile}
          helper_position = rendering.position(#{helper.position.line_number},
            #{helper.position.line_offset})

          result = rendering.call(helper, #{helper.path.inspect}, helper_position, context, options) do
            # A helper always yields an empty template
            ''
          end
          buffer.safe_concat(result.to_s)
        RUBY
      end

      def validate(trees)
        [
          helper.validate(trees, check_type: :leaf),
          context.validate(trees),
          options.map { |option| option.validate(trees) }
        ]
      end
    end
  end
end
