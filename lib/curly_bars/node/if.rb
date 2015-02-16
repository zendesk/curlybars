module CurlyBars
  module Node
    If = Struct.new(:expression, :template) do
      def compile
        <<-RUBY
          buffer = ActiveSupport::SafeBuffer.new
          if #{expression.compile}
            buffer.safe_concat(#{template.compile})
          end
          buffer
        RUBY
      end
    end
  end
end
