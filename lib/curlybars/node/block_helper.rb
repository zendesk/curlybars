require 'curlybars/error/compile'

module Curlybars
  module Node
    BlockHelper = Struct.new(:helper, :context, :options, :template, :helperclose, :position) do
      def compile
        check_open_and_close_elements(helper, helperclose, Curlybars::Error::Compile)

        compiled_options = options.map do |option|
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
            contexts.push(block_helper_context)
            begin
              #{template.compile}
            ensure
              contexts.pop
            end
          end
          buffer.safe_concat(result.to_s)
        RUBY
      end

      def validate(branches)
        check_open_and_close_elements(helper, helperclose, Curlybars::Error::Validate)

        helper_tree = helper.resolve_and_check!(branches, check_type: :presenter)
        template_errors = begin
          branches.push(helper_tree)
          template.validate(branches)
        ensure
          branches.pop
        end
        [
          template_errors,
          context.validate(branches, check_type: :presenter),
          options.map { |option| option.validate(branches) }
        ]
      rescue Curlybars::Error::Validate => path_error
        path_error
      end

      private

      def check_open_and_close_elements(helper, helperclose, error_class)
        return unless helper.path != helperclose.path
        message = "block `#{helper.path}` cannot be closed by `#{helperclose.path}`"
        raise error_class.new('closing_tag_mismatch', message, helperclose.position)
      end
    end
  end
end
