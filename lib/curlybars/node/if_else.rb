module Curlybars
  module Node
    IfElse = Struct.new(:expression, :if_template, :else_template) do
      def compile
        <<-RUBY
          if rendering.to_bool(#{expression.compile}.call)
            buffer.safe_concat(#{if_template.compile})
          else
            buffer.safe_concat(#{else_template.compile})
          end
        RUBY
      end

      def validate(base_tree)
        [
          expression.validate(base_tree),
          if_template.validate(base_tree),
          else_template.validate(base_tree)
        ]
      end
    end
  end
end
