module Curlybars
  module Node
    String = Struct.new(:string) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          ->() { #{string.inspect} }
        RUBY
      end

      def validate(branches)
        # Nothing to validate here.
      end
    end
  end
end
