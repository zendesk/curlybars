# frozen_string_literal: true

module Curlybars
  module Node
    Variable = Struct.new(:variable, :position) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          -> { rendering.variable(#{variable.inspect}, rendering.position(#{position.line_number}, #{position.line_offset})) }
        RUBY
      end

      def validate(branches, check_type: :anything, context: nil)
        # Nothing to validate here.
      end

      def validate_as_value(branches)
        # It is always a value.
      end

      def cache_key
        [
          variable,
          self.class.name
        ].join("/")
      end
    end
  end
end
