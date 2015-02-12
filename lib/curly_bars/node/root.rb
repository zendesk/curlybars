module CurlyBars
  module Node
    Root = Struct.new(:template) do
      def compile
        <<-RUBY
          contexts = [presenter]
          buffer = ActiveSupport::SafeBuffer.new
          #{template.compile}
          buffer
        RUBY
      end
    end
  end
end
