module Curlybars
  module Node
    SubExpression = Struct.new(:helper, :arguments, :options, :position) do
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

                options[:this] = contexts.last

                rendering.call(helper, #{helper.path.inspect}, helper_position,
                  arguments, options)
              }
            end
          end.exec(contexts, rendering)
        RUBY
      end

      def validate(branches, check_type: :anything)
        if helper.helper?(branches)
          [
            helper.validate(branches),
            arguments.map { |argument| argument.validate_as_value(branches) },
            options.map { |option| option.validate(branches) }
          ]
        else
          message = "#{helper.path} must be allowed as a helper"
          Curlybars::Error::Validate.new('invalid_subexpression_helper', message, helper.position)
        end
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
