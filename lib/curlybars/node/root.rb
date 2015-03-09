module Curlybars
  module Node
    Root = Struct.new(:template, :position) do
      def compile
        <<-RUBY
          contexts = [presenter]
          rendering = Curlybars::RenderingSupport.new(contexts, #{position.file_name.inspect})
          variables = [{}]
          #{template.compile}
        RUBY
      end

      def validate(branches)
        template.validate(branches)
      end
    end
  end
end
