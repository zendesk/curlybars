require 'curlybars/error/compile'

module Curlybars
  module Node
    BlockHelper = Struct.new(:helper, :context, :options, :template, :helperclose, :position) do
      def initialize(helper, context, options, template, helperclose, position)
        if helper.path != helperclose.path
          message = "block `#{helper.path}` cannot be closed by `#{helperclose.path}`"
          raise Curlybars::Error::Compile.new('closing_tag_mismatch', message, helperclose.position)
        end
        super
      end

      def compile
        compiled_options = (options || []).map do |option|
          "options.merge!(#{option.compile})"
        end.join("\n")

        <<-RUBY
          options = ActiveSupport::HashWithIndifferentAccess.new
          #{compiled_options}

          context = #{context.compile}.call

          unless context.nil?
            context_position = rendering.position(#{context.position.line_number},
              #{context.position.line_offset})
            rendering.check_context_is_presenter(context, #{context.path.inspect},
              context_position)
          end

          helper = #{helper.compile}
          helper_position = rendering.position(#{helper.position.line_number},
            #{helper.position.line_offset})

          result = rendering.call(helper, #{helper.path.inspect}, helper_position, context, options) do |block_helper_context = context|
            break '' if block_helper_context.nil?
            contexts << block_helper_context
            begin
              #{template.compile}
            ensure
              contexts.pop
            end
          end
          buffer.safe_concat(result.to_s)
        RUBY
      end

      def validate(dependency_tree)
        sub_tree = context.resolve_on(dependency_tree, check_type: :presenter)
        [
          helper.validate(dependency_tree, check_type: :leaf),
          options.map { |option| option.validate(dependency_tree) },
          template.validate(sub_tree)
        ]
      rescue Curlybars::Error::Validate => path_error
        path_error
      end
    end
  end
end
