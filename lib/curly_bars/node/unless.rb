module CurlyBars
  module Node
    Unless = Struct.new(:expression, :template) do
      def compile
        <<-RUBY
          buffer = ActiveSupport::SafeBuffer.new
          unless #{expression.compile}
            buffer.safe_concat(#{template.compile})
          end
          buffer
        RUBY
      end
    end
  end
end
