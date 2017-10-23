module Curlybars
  module Node
    Boolean = Struct.new(:boolean) do
      def compile
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
