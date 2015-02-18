module Curlybars
  module Node
    UnlessElse = Struct.new(:expression, :unless_template, :else_template) do
      def compile
        <<-RUBY
          unless hbs.to_bool(#{expression.compile}.call)
            #{unless_template.compile}
          else
            #{else_template.compile}
          end
        RUBY
      end
    end
  end
end
