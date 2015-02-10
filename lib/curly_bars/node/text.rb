module CurlyBars
  module Node
    class Text
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def compile
        "buffer.safe_concat(#{value.inspect})"
      end
    end
  end
end
