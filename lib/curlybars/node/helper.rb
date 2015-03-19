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
          context = rendering.cached_call(#{context.compile})
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

      def validate(branches)
        [
          helper.validate(branches, check_type: :leaf),
          context.validate(branches),
          options.map { |option| option.validate(branches) }
        ]
      end
    end
  end
end
