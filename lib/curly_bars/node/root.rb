module CurlyBars
  module Node
    class Root
      attr_reader :template

      def initialize(template)
        @template = template
      end

      def compile
<<-RUBY
contexts = [self]
buffer = ActiveSupport::SafeBuffer.new
#{template.join("\n")}
buffer
RUBY
      end
    end
  end
end
