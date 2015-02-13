module CurlyBars
  module Node
    Text = Struct.new(:text) do
      def compile
        <<-RUBY
          ActiveSupport::SafeBuffer.new(#{text.inspect})
        RUBY
      end
    end
  end
end
