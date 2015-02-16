module CurlyBars
  module Node
    Text = Struct.new(:text) do
      def compile
        ActiveSupport::SafeBuffer.new(text.inspect)
      end
    end
  end
end
