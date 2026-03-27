module Curlybars
  module Node
    Root = Struct.new(:template, :position) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          contexts = [presenter]
          variables = [{}]
          has_rendering_context = defined?(rendering_context)
          rendering = ::Curlybars::RenderingSupport.new(
            ::Curlybars.configuration.rendering_timeout,
            contexts,
            variables,
            #{position.file_name.inspect},
            global_helpers_providers,
            ::Curlybars.configuration.cache,
            start_time: has_rendering_context ? rendering_context[:start_time] : nil,
            depth: has_rendering_context ? rendering_context[:depth] : 0,
            partial_provider: partial_provider
          )
          buffer = ::Curlybars::SafeBuffer.new
          #{template.compile}
          buffer
        RUBY
      end

      def validate(branches, context: nil)
        template.validate(branches, context: context)
      end
    end
  end
end
