module Curlybars
  module Node
    Root = Struct.new(:template, :position) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          contexts = [presenter]
          variables = [{}]
          _cb_start = Thread.current[:curlybars_render_start_time]
          Thread.current[:curlybars_render_start_time] = nil
          rendering = ::Curlybars::RenderingSupport.new(
            ::Curlybars.configuration.rendering_timeout,
            contexts,
            variables,
            #{position.file_name.inspect},
            global_helpers_providers,
            ::Curlybars.configuration.cache,
            _cb_start
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
