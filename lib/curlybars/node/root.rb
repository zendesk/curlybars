module Curlybars
  module Node
    Root = Struct.new(:template, :position) do
      def compile
        <<-RUBY
          contexts = [presenter]
          variables = [{}]
          rendering = Curlybars::RenderingSupport.new(
            contexts,
            variables,
            #{position.file_name.inspect}
          )
          #{template.compile}
        RUBY
      end

      def validate(branches)
        template.validate(branches)
      end
    end
  end
end
