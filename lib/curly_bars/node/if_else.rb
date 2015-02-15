module CurlyBars
  module Node
    IfElse = Struct.new(:expression, :if_template, :else_template) do
      def compile
        <<-RUBY
          if #{expression.compile}
            #{if_template.compile}
          else
            #{else_template.compile}
          end
        RUBY
      end
    end
  end
end
