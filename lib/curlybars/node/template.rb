module Curlybars
  module Node
    Template = Struct.new(:items, :position) do
      def compile
        compiled_items = items.map(&:compile).join("\n")

        <<-RUBY
          Module.new do
            def self.exec(contexts, rendering, variables)
              unless contexts.length < Curlybars.configuration.nesting_limit
                message = "Nesting too deep"
                position = rendering.position(#{position.line_number}, #{position.line_offset})
                raise Curlybars::Error::Render.new('nesting_too_deep', message, position)
              end
              buffer = ActiveSupport::SafeBuffer.new
              #{compiled_items}
              buffer
            end
          end.exec(contexts, rendering, variables)
        RUBY
      end

      def validate(branches)
        items.map { |item| item.validate(branches) }
      end
    end
  end
end
