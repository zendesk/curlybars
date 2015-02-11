module CurlyBars
  module Node
    class With
      attr_reader :path, :template

      def initialize(path, template)
        @path = path
        @template = template
      end

      def compile
        t = template.join("\n")
<<-RUBY
contexts << #{path}
#{t}
contexts.pop
RUBY
      end
    end
  end
end
