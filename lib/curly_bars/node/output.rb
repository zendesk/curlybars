module CurlyBars
  module Node
    Output = Struct.new(:expression) do
      def compile
        <<-RUBY
          buffer << #{expression.compile}
        RUBY
      end
    end
  end
end
