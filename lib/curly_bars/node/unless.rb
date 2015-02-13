module CurlyBars
  module Node
    Unless = Struct.new(:expression, :template) do
      def compile
        <<-RUBY
          buffer = ActiveSupport::SafeBuffer.new
          unless begin
            #{expression.compile}
          end
            buffer.safe_concat begin
              #{template.compile}
            end
          end
          buffer
        RUBY
      end
    end
  end
end
