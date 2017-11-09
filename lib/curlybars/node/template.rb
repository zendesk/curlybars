module Curlybars
  module Node
    Template = Struct.new(:items, :position) do
      def compile
        compiled_items = items.map(&:compile).join("\n")

        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          ::Module.new do
            def self.exec(contexts, rendering, variables, buffer)
              unless contexts.length < ::Curlybars.configuration.nesting_limit
                message = "Nesting too deep"
                position = rendering.position(#{position.line_number}, #{position.line_offset})
                raise ::Curlybars::Error::Render.new('nesting_too_deep', message, position)
              end
              #{compiled_items}
            end
          end.exec(contexts, rendering, variables, buffer)
        RUBY
      end

      def validate(branches)
        items.map { |item| item.validate(branches) }
      end

      def cache_key
        Digest::MD5.hexdigest(items.map(&:cache_key).join("/"))
      end
    end
  end
end
