module Curlybars
  module Node
    Json = Struct.new(:path) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          buffer.concat(rendering.cached_call(#{path.compile}).to_json)
        RUBY
      end

      def validate(branches)
        # TODO
      end

      def cache_key
        # TODO
        [
          path.cache_key,
          self.class.name
        ].join("/")
      end
    end
  end
end
