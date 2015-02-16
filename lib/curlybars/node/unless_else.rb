module Curlybars
  module Node
    UnlessElse = Struct.new(:expression, :unless_template, :else_template) do
      def compile
        <<-RUBY
          unless #{expression.compile}
            #{unless_template.compile}
          else
            #{else_template.compile}
          end
        RUBY
      end
    end
  end
end
