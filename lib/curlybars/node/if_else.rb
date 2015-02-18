module Curlybars
  module Node
    IfElse = Struct.new(:expression, :if_template, :else_template) do
      def compile
        <<-RUBY
          if hbs.to_bool(#{expression.compile}.call)
            #{if_template.compile}
          else
            #{else_template.compile}
          end
        RUBY
      end
    end
  end
end
