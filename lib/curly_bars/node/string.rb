module CurlyBars
  module Node
    String = Struct.new(:string) do
      def compile
        ActiveSupport::SafeBuffer.new(string.inspect)
      end
    end
  end
end
