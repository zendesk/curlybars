module Curlybars
  module Node
    Root = Struct.new(:template, :position) do
      def compile
        <<-RUBY
          contexts = [presenter]
          variables = [{}]
          rendering = ::Curlybars::RenderingSupport.new(
            ::Curlybars.configuration.rendering_timeout,
            contexts,
            variables,
            #{position.file_name.inspect},
            global_helpers_providers,
            ::Curlybars.configuration.cache
          )
          buffer = ::Curlybars::SafeBuffer.new
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
