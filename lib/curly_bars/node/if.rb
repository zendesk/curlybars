module CurlyBars
  module Node
    If = Struct.new(:expression, :template) do
      def compile
        <<-RUBY
          if #{expression.compile}
            buffer.safe_concat(#{template.compile})
          end
        RUBY
      end
    end
  end
end
