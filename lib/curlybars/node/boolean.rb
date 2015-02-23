module Curlybars
  module Node
    Boolean = Struct.new(:boolean) do
      def compile
        <<-RUBY
          ->() { #{boolean} }
        RUBY
      end
    end
  end
end
