module Curlybars
  module Node
    String = Struct.new(:string) do
      def compile
        <<-RUBY
          ->() { #{string.inspect} }
        RUBY
      end
    end
  end
end
