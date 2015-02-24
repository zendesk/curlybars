module Curlybars
  module Node
    Integer = Struct.new(:integer) do
      def compile
        <<-RUBY
          ->() { #{integer} }
        RUBY
      end
    end
  end
end
