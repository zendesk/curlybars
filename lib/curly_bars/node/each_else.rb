module CurlyBars
  module Node
    EachElse = Struct.new(:expression, :template) do
      def compile
        <<-RUBY
          buffer = ActiveSupport::SafeBuffer.new
          #{expression.compile}.each do
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
