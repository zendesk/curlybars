module CurlyBars
  module Node
    Root = Struct.new(:template) do
      def compile
        <<-RUBY
          buffer = ActiveSupport::SafeBuffer.new
          contexts = [presenter]
          #{template.compile}
          buffer
        RUBY
      end
    end
  end
end
