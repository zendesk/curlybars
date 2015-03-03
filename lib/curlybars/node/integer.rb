module Curlybars
  module Node
    Integer = Struct.new(:integer) do
      def compile
        <<-RUBY
          ->() { #{integer} }
        RUBY
      end

      def validate(base_tree)
        # Nothing to validate here.
      end
    end
  end
end
