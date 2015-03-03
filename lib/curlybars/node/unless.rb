module Curlybars
  module Node
    Unless = Struct.new(:expression, :template) do
      def compile
        <<-RUBY
          unless rendering.to_bool(#{expression.compile}.call)
            buffer.safe_concat(#{template.compile})
          end
        RUBY
      end

      def validate(base_tree)
        [
          expression.validate(base_tree),
          template.validate(base_tree)
        ]
      end
    end
  end
end
