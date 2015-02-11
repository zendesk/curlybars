module CurlyBars
  module Node
    class Output
      attr_reader :expression

      def initialize(expression)
        @expression = expression
      end

      def compile
        "buffer << #{expression}"
      end
    end
  end
end
