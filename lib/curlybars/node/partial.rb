module Curlybars
  module Node
    Partial = Struct.new(:path, :options, :position) do
      def compile
        compiled_options = options.map do |option|
          "options.merge!(#{option.compile})"
        end.join("\n")

        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          options = ::ActiveSupport::HashWithIndifferentAccess.new
          #{compiled_options}

          partial_source = rendering.resolve_partial(#{path.path.inspect})
          if partial_source
            buffer.concat(rendering.render_partial(partial_source, #{path.path.inspect}, options).to_s)
          else
            buffer.concat(rendering.cached_call(#{path.compile}).to_s)
          end
        RUBY
      end

      def validate(branches)
        # Path validation is lenient — partials may be resolved at runtime
        # by a provider's resolve_partial method.
        options.flat_map { |option| option.expression.validate(branches) }
      end

      def cache_key
        [
          path.cache_key,
          options.map(&:cache_key).join("/"),
          position&.file_name,
          self.class.name
        ].join("/")
      end
    end
  end
end
