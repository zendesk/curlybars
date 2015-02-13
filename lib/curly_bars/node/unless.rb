module CurlyBars
  module Node
    Unless = Struct.new(:expression, :template) do
      def compile
        <<-RUBY
          unless #{expression.compile}
            buffer.safe_concat(#{template.compile})
          end
        RUBY
      end
    end
  end
end
