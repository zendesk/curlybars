module CurlyBars
  module Node
    Root = Struct.new(:template) do
      def compile
        <<-RUBY
          buffer = ActiveSupport::SafeBuffer.new
          buffers = []
          contexts = [presenter]
          #{template.compile}
          buffer
        RUBY
      end
    end
  end
end
