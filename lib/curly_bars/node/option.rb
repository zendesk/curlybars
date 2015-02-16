module CurlyBars
  module Node
    Option = Struct.new(:key, :expression) do
      def compile
        "{#{key.to_s.inspect} => #{expression.compile}}"
      end
    end
  end
end
