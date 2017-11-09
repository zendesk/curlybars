module Curlybars
  module Node
    Output = Struct.new(:value) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          buffer.concat(rendering.cached_call(#{value.compile}).to_s)
        RUBY
      end

      def validate(branches)
        value.validate(branches)
      end

      def cache_key
        [
          value.cache_key,
          self.class.name
        ].join("/")
      end
    end
  end
end
