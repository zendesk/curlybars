module Curlybars
  module Node
    IfElse = Struct.new(:expression, :if_template, :else_template) do
      def compile
        <<-RUBY
          if rendering.to_bool(rendering.cached_call(#{expression.compile}))
            #{if_template.compile}
          else
            #{else_template.compile}
          end
        RUBY
      end

      def validate(branches)
        [
          expression.validate(branches),
          if_template.validate(branches),
          else_template.validate(branches)
        ]
      end
    end
  end
end
