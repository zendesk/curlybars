module Curlybars
  module Node
    Literal = Struct.new(:literal) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          ->() { #{literal} }
        RUBY
      end

      def validate(branches)
        # Nothing to validate here.
      end

      def validate_as_value(branches)
        # It is always a value.
      end

      def cache_key
        [
          literal.to_s,
          self.class.name
        ].join("/")
      end
    end
  end
end
