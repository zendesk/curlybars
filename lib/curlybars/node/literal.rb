module Curlybars
  module Node
    Literal = Struct.new(:literal) do
      def compile
        <<-RUBY
          ->() { #{literal} }
        RUBY
      end

      def validate(branches)
        # Nothing to validate here.
      end
    end
  end
end
