module Curlybars
  module Node
    Option = Struct.new(:key, :expression) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          { #{key.to_s.inspect} => rendering.cached_call(#{expression.compile}) }
        RUBY
      end

      def validate(branches)
        expression.validate_as_value(branches)
      end

      def cache_key
        [
          key,
          expression.cache_key,
          self.class.name
        ].join("/")
      end
    end
  end
end
