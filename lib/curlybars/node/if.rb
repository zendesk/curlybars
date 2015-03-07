module Curlybars
  module Node
    If = Struct.new(:expression, :template) do
      def compile
        <<-RUBY
          if rendering.to_bool(#{expression.compile}.call)
            buffer.safe_concat(#{template.compile})
          end
        RUBY
      end

      def validate(trees)
        [
          expression.validate(trees),
          template.validate(trees)
        ]
      end
    end
  end
end
