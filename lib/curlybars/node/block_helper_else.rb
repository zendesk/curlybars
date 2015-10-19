require 'curlybars/error/compile'

module Curlybars
  module Node
    BlockHelperElse = Struct.new(:helper, :arguments, :options, :helper_template, :else_template, :helperclose, :position) do
      def compile
        check_open_and_close_elements(helper, helperclose, Curlybars::Error::Compile)

        compiled_arguments = arguments.map do |argument|
          "arguments.push(rendering.cached_call(#{argument.compile}))"
        end.join("\n")

        compiled_options = options.map do |option|
          "options.merge!(#{option.compile})"
        end.join("\n")

        <<-RUBY
          options = ::ActiveSupport::HashWithIndifferentAccess.new
          #{compiled_options}

          arguments = []
          #{compiled_arguments}

          helper = #{helper.compile}
          helper_position = rendering.position(#{helper.position.line_number},
            #{helper.position.line_offset})

          options[:fn] = ->(**vars) do
            variables.push(vars.symbolize_keys)
            outer_buffer = buffer
            begin
              buffer = ::Curlybars::SafeBuffer.new
              #{helper_template.compile}
              buffer
            ensure
              buffer = outer_buffer
              variables.pop
            end
          end

          options[:inverse] = ->(**vars) do
            variables.push(vars.symbolize_keys)
            outer_buffer = buffer
            begin
              buffer = ::Curlybars::SafeBuffer.new
              #{else_template.compile}
              buffer
            ensure
              buffer = outer_buffer
              variables.pop
            end
          end

          options[:this] = contexts.last

          result = rendering.call(helper, #{helper.path.inspect}, helper_position,
            arguments, options, &options[:fn])

          unless rendering.presenter?(result) || rendering.presenter_collection?(result)
            buffer.concat(result.to_s)
          end
        RUBY
      end

      def validate(branches)
        check_open_and_close_elements(helper, helperclose, Curlybars::Error::Validate)

        if helper.leaf?(branches)
          if arguments.any? || options.any?
            message = "#{helper.path} doesn't accept any arguments or options"
            Curlybars::Error::Validate.new('invalid_signature', message, helper.position)
          end
        elsif helper.helper?(branches)
          [
            helper_template.validate(branches),
            else_template.validate(branches),
            arguments.map { |argument| argument.validate_as_value(branches) },
            options.map { |option| option.validate(branches) }
          ]
        else
          message = "#{helper.path} must be allowed as helper or leaf"
          Curlybars::Error::Validate.new('invalid_block_helper', message, helper.position)
        end
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
