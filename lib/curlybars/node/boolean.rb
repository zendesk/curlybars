module Curlybars
  module Node
    Boolean = Struct.new(:boolean) do
      def compile
        <<-RUBY
          ->() { #{boolean} }
        RUBY
      end

      def validate(trees)
        # Nothing to validate here.
      end
    end
  end
end
