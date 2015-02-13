module CurlyBars
  module Node
    IfElse = Struct.new(:expression, :if_template, :else_template) do
      def compile
        <<-RUBY
          if #{expression.compile}
            buffer.safe_concat(#{if_template.compile})
          else
            buffer.safe_concat(#{else_template.compile})
          end
        RUBY
      end
    end
  end
end
