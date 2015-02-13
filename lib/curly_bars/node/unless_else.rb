module CurlyBars
  module Node
    UnlessElse = Struct.new(:expression, :unless_template, :else_template) do
      def compile
        <<-RUBY
          buffer = ActiveSupport::SafeBuffer.new
          unless begin
            #{expression.compile}
          end
            buffer.safe_concat begin
              #{unless_template.compile}
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
