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
            #{position.file_name.inspect},
            global_helpers_providers
          )
          buffer = Curlybars::SafeBuffer.new
          #{template.compile}
          buffer
        RUBY
      end

      def validate(branches)
        template.validate(branches)
      end
    end
  end
end
