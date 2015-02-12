module CurlyBars
  module Node
    Text = Struct.new(:text) do
      def compile
        <<-RUBY
          buffer.safe_concat(#{text.inspect})
        RUBY
      end
    end
  end
end
