module Curlybars
  module Node
    String = Struct.new(:string) do
      def compile
        <<-RUBY
          ->() { #{string.inspect} }
        RUBY
      end

      def validate(base_tree)
        # Nothing to validate here.
      end
    end
  end
end
