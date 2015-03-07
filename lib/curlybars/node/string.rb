module Curlybars
  module Node
    String = Struct.new(:string) do
      def compile
        <<-RUBY
          ->() { #{string.inspect} }
        RUBY
      end

      def validate(trees)
        # Nothing to validate here.
      end
    end
  end
end
