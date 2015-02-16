module Curlybars
  module Node
    With = Struct.new(:path, :template) do
      def compile
        <<-RUBY
          contexts << #{path.compile}
          begin
            #{template.compile}
          ensure
            contexts.pop
          end
        RUBY
      end
    end
  end
end
