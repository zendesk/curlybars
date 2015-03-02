module Curlybars
  module Node
    Root = Struct.new(:template, :position) do
      def compile
        <<-RUBY
          contexts = [presenter]
          rendering = Curlybars::RenderingSupport.new(contexts, #{position.file_name.inspect})
          #{template.compile}
        RUBY
      end
    end
  end
end
