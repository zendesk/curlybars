module CurlyBars
  module Node
    With = Struct.new(:path, :template) do
      def compile
        <<-RUBY
          contexts << #{path}
          #{template.compile}
          contexts.pop
        RUBY
      end
    end
  end
end
