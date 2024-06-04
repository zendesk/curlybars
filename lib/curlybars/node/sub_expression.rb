module Curlybars
  module Node
    SubExpression = Struct.new(:helper, :arguments, :options, :position) do
      def subexpression?
        true
      end

      def compile
        compiled_arguments = arguments.map do |argument|
          "arguments.push(rendering.cached_call(#{argument.compile}))"
        end.join("\n")

        compiled_options = options.map do |option|
          "options.merge!(#{option.compile})"
        end.join("\n")

        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          ::Module.new do
            def self.exec(contexts, rendering)
              rendering.check_timeout!

              -> {
                options = ::ActiveSupport::HashWithIndifferentAccess.new
                #{compiled_options}

                arguments = []
                #{compiled_arguments}

                helper = #{helper.compile}
                helper_position = rendering.position(#{helper.position.line_number},
                  #{helper.position.line_offset})

                options[:fn] = -> {}
                options[:inverse] = -> {}
                options[:this] = contexts.last

                rendering.call(helper, #{helper.path.inspect}, helper_position,
                  arguments, options)
              }
            end
          end.exec(contexts, rendering)
        RUBY
      end

      def validate_as_value(branches, check_type: :anything)
        validate(branches, check_type: check_type)
      end

      def validate(branches, check_type: :anything)
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

        if helper?(type)
          if generic_helper?(type)
            is_collection = type.last.is_a?(Array)
            return infer_generic_helper_type!(branches, is_collection: is_collection)
          end

          return type.last
        end

        type
      end

      def generic_helper?(type)
        return false unless type.is_a?(Array)
        return false unless type.size == 2
        return false unless type.first == :helper

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
