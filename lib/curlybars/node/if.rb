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

      def validate(branches)
        [
          expression.validate(branches),
          template.validate(branches)
        ]
      end
    end
  end
end
