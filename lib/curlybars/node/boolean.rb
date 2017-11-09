module Curlybars
  module Node
    Boolean = Struct.new(:boolean) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          ->() { #{boolean} }
        RUBY
      end

      def validate(branches)
        # Nothing to validate here.
      end

      def cache_key
        [
          boolean.to_s,
          self.class.name
        ].join("/")
      end
    end
  end
end
