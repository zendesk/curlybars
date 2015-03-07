module Curlybars
  module Node
    UnlessElse = Struct.new(:expression, :unless_template, :else_template) do
      def compile
        <<-RUBY
          unless rendering.to_bool(#{expression.compile}.call)
            buffer.safe_concat(#{unless_template.compile})
          else
            buffer.safe_concat(#{else_template.compile})
          end
        RUBY
      end
    end

    def validate(trees)
      [
        expression.validate(trees),
        unless_template.validate(trees),
        else_template.validate(trees)
      ]
    end
  end
end
