# frozen_string_literal: true

module Curlybars
  module Node
    SubExpression = Struct.new(:helper, :arguments, :options, :position) do
      def subexpression?
        true
      end

      def compile
        compiled_options = options.map { |option| option.compile.strip }.join(", ")
        compiled_arguments = arguments.map { |argument| "rendering.cached_call(#{argument.compile.strip})" }.join(", ")

        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        CompiledMethods.define("sub_expression", "contexts, rendering", <<-RUBY)
          rendering.check_timeout!

          -> {
            rendering.call_subexpression([#{compiled_options}], [#{compiled_arguments}],
              #{helper.compile.strip}, #{helper.path.inspect},
              #{helper.position.line_number}, #{helper.position.line_offset})
          }
        RUBY
      end

      def validate_as_value(branches, check_type: :anything)
        validate(branches, check_type: check_type)
      end

      def validate(branches, check_type: :anything, context: nil)
        [
          helper.validate(branches, check_type: :helper),
          arguments.map { |argument| argument.validate_as_value(branches) },
          options.map { |option| option.validate(branches) }
        ]
      end

      def resolve_and_check!(branches, check_type: :collectionlike)
        node = if arguments.first.is_a?(Curlybars::Node::SubExpression)
          arguments.first
        else
          helper
        end

        type = node.resolve_and_check!(branches, check_type: check_type)

        if generic_helper?(type)
          is_collection = type.last.is_a?(Array)
          infer_generic_helper_type!(branches, is_collection: is_collection)
        elsif helper?(type)
          type.last
        else
          type
        end
      end

      def generic_helper?(type)
        return false unless helper?(type)
        return false unless type.size == 2

        type.last == [{}] || type.last == {}
      end

      def helper?(type)
        type.first == :helper
      end

      def infer_generic_helper_type!(branches, is_collection:)
        if arguments.empty?
          raise Curlybars::Error::Validate.new('missing_path', "'#{helper.path}' requires a collection as its first argument", helper.position)
        end

        check_type = is_collection ? :presenter_collection : :presenter
        arguments.first.resolve_and_check!(branches, check_type: check_type)
      end

      def cache_key
        [
          helper,
          arguments,
          options
        ].flatten.map(&:cache_key).push(self.class.name).join("/")
      end
    end
  end
end
