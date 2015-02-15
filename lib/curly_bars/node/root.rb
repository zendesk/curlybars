module CurlyBars
  module Node
    Root = Struct.new(:template) do
      def compile
        <<-RUBY
          contexts = [presenter]
          ActiveSupport::SafeBuffer.new(#{template.compile})
        RUBY
      end
    end
  end
end
