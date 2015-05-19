require 'curlybars/error/compile'

module Curlybars
  module Node
    BlockHelperElse = Struct.new(:helper, :context, :options, :helper_template, :else_template, :helperclose, :position) do
      def compile
        check_open_and_close_elements(helper, helperclose, Curlybars::Error::Compile)

        compiled_options = options.map do |option|
          "options.merge!(#{option.compile})"
        end.join("\n")

        <<-RUBY
          options = ActiveSupport::HashWithIndifferentAccess.new
          #{compiled_options}

          context = rendering.cached_call(#{context.compile})

          unless context.nil?
            context_position = rendering.position(#{context.position.line_number},
              #{context.position.line_offset})
            rendering.check_context_is_presenter(context, #{context.path.inspect},
              context_position)
          end

          helper = #{helper.compile}
          helper_position = rendering.position(#{helper.position.line_number},
            #{helper.position.line_offset})
          fn = ->(block_helper_context = context, **vars) do
            break if block_helper_context.nil?
            begin
              contexts.push(block_helper_context)
              variables.push(vars.symbolize_keys)
              outer_buffer = buffer
              buffer = Curlybars::SafeBuffer.new
              #{helper_template.compile}
              buffer
            ensure
              buffer = outer_buffer
              variables.pop
              contexts.pop
            end
          end

          options[:fn] = fn

          inverse = ->(**vars) do
            begin
              variables.push(vars.symbolize_keys)
              outer_buffer = buffer
              buffer = Curlybars::SafeBuffer.new
              #{else_template.compile}
              buffer
            ensure
              buffer = outer_buffer
              variables.pop
            end
          end

          options[:inverse] = inverse

          result = rendering.call(helper, #{helper.path.inspect}, helper_position,
            context, options, &fn)

          buffer.safe_concat(result.to_s)
        RUBY
      end

      def validate(branches)
        check_open_and_close_elements(helper, helperclose, Curlybars::Error::Validate)

        helper_tree = helper.resolve_and_check!(branches, check_type: :presenter)
        helper_template_errors = begin
          branches.push(helper_tree)
          helper_template.validate(branches)
        ensure
          branches.pop
        end

        else_template_errors = else_template.validate(branches)
        [
          helper_template_errors,
          else_template_errors,
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
