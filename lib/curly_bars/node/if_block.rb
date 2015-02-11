module CurlyBars
  module Node
    class IfBlock
      attr_reader :expression, :template

      def initialize(expression, template)
        @expression = expression
        @template = template
      end

      def compile
        t = template.join("\n")
        "if #{expression}\n  #{t}\nend\n"
      end
    end
  end
end
