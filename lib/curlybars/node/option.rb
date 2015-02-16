module Curlybars
  module Node
    Option = Struct.new(:key, :expression) do
      def compile
        "{#{key.to_s.inspect} => #{expression.compile}.call}"
      end
    end
  end
end
