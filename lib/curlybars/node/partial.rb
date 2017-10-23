module Curlybars
  module Node
    Partial = Struct.new(:path) do
      def compile
        <<-RUBY
          buffer.concat(rendering.cached_call(#{path.compile}).to_s)
        RUBY
      end

      def validate(branches)
        path.validate(branches, check_type: :partial)
      end

      def cache_key
        [
          path.cache_key,
          self.class.name
        ].join("/")
      end
    end
  end
end
