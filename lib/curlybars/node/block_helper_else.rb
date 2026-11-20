# frozen_string_literal: true

require 'curlybars/error/compile'

module Curlybars
  module Node
    BlockHelperElse = Struct.new(:helper, :arguments, :options, :helper_template, :else_template, :helperclose, :position) do
      def compile
        check_open_and_close_elements(helper, helperclose, Curlybars::Error::Compile)

        compiled_options = options.map { |option| option.compile.strip }.join(", ")
        compiled_arguments = arguments.map { |argument| "rendering.cached_call(#{argument.compile.strip})" }.join(", ")

        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          rendering.render_helper(buffer, [#{compiled_options}], [#{compiled_arguments}],
            #{helper.compile.strip}, #{helper.path.inspect},
            #{helper.position.line_number}, #{helper.position.line_offset},
            #{compile_block(helper_template)}, #{compile_block(else_template)})
        RUBY
      end

      def validate(branches, context: nil)
        check_open_and_close_elements(helper, helperclose, Curlybars::Error::Validate)

        if helper.leaf?(branches)
          if arguments.any? || options.any?
            message = "#{helper.path} doesn't accept any arguments or options"
            Curlybars::Error::Validate.new('invalid_signature', message, helper.position)
          end
        elsif helper.helper?(branches)
          [
            helper_template.validate(branches, context: context),
            else_template.validate(branches, context: context),
            arguments.map { |argument| argument.validate_as_value(branches) },
            options.map { |option| option.validate(branches) }
          ]
        elsif helper.generic_helper?(branches)
          if arguments.empty?
            message = "#{helper.path} requires an argument"
            Curlybars::Error::Validate.new('invalid_signature', message, helper.position)
          else
            [
              helper_template.validate(branches, context: context),
              else_template.validate(branches, context: context),
              arguments.map { |argument| argument.validate(branches, check_type: :anything) },
              options.map { |option| option.validate(branches) }
            ]
          end
        else
          message = "#{helper.path} must be allowed as helper or leaf"
          Curlybars::Error::Validate.new('invalid_block_helper', message, helper.position)
        end
      end

      def cache_key
        [
          helper,
          arguments,
          options,
          helper_template,
          else_template,
          helperclose
        ].flatten.map(&:cache_key).push(self.class.name).join("/")
      end

      private

      # Templates compile to `nil` when empty (see `Parser::VOID`), in which
      # case `RenderingSupport#render_helper` uses an empty block.
      def compile_block(template)
        compiled = template.compile
        return "nil" if compiled.nil?

        "->(**vars) { rendering.capture(vars) { |buffer| #{compiled} } }"
      end

      def check_open_and_close_elements(helper, helperclose, error_class)
        return unless helper.path != helperclose.path

        message = "block `#{helper.path}` cannot be closed by `#{helperclose.path}`"
        raise error_class.new('closing_tag_mismatch', message, helperclose.position)
      end
    end
  end
end
