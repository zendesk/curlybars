module Curlybars
  module Node
    Item = Struct.new(:item) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          ::Module.new do
            def self.exec(contexts, rendering, variables, buffer)
              rendering.check_timeout!
              #{item.compile}
            end
          end.exec(contexts, rendering, variables, buffer)
        RUBY
      end

      def validate(branches)
        item.validate(branches)
      end

      def cache_key
        [
          item.cache_key,
          self.class.name
        ].join("/")
      end
    end
  end
end
