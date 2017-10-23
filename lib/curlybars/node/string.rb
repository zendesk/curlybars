module Curlybars
  module Node
    String = Struct.new(:string) do
      def compile
        <<-RUBY
          ->() { #{string.inspect} }
        RUBY
      end

      def validate(branches)
        # Nothing to validate here.
      end

      def cache_key
        [
          string,
          self.class.name
        ].join("/")
      end
    end
  end
end
