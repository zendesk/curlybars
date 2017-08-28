module Curlybars
  module Node
    Partial = Struct.new(:path) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          buffer.concat(rendering.cached_call(#{path.compile}).to_s)
        RUBY
      end

      def validate(branches)
        path.validate(branches, check_type: :partial)
      end
    end
  end
end
