module CurlyBars
  module Node
    Text = Struct.new(:text) do
      def compile
        <<-RUBY
          buffer << "#{text}"
        RUBY
      end
    end
  end
end
