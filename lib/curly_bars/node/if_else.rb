module CurlyBars
  module Node
    IfElse = Struct.new(:expression, :if_template, :else_template) do
      def compile
        <<-RUBY
          buffer = ActiveSupport::SafeBuffer.new
          if #{expression.compile}
            buffer.safe_concat begin
              #{if_template.compile}
            end
          else
            buffer.safe_concat begin
              #{else_template.compile}
            end
          end
          buffer
        RUBY
      end
    end
  end
end
