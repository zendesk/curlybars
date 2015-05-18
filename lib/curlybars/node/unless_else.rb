module Curlybars
  module Node
    UnlessElse = Struct.new(:expression, :unless_template, :else_template) do
      def compile
        <<-RUBY
          unless rendering.to_bool(rendering.cached_call(#{expression.compile}))
            #{unless_template.compile}
          else
            #{else_template.compile}
          end
        RUBY
      end

      def validate(branches)
        [
          expression.validate(branches),
          unless_template.validate(branches),
          else_template.validate(branches)
        ]
      end
    end
  end
end
