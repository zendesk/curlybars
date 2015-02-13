module CurlyBars
  module Node
    IfBlock = Struct.new(:expression, :template) do
      def compile
        <<-RUBY
          if #{expression.compile}
            #{template.compile}
          end
        RUBY
      end
    end
  end
end
