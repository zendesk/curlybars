module Curlybars
  module Node
    Template = Struct.new(:items, :position) do
      def compile
        compiled_items = (items || []).map(&:compile).join("\n")

        <<-RUBY
          Module.new do
            def self.exec(contexts, hbs)
              unless contexts.length < 10
                message = "Nesting too deep"
                raise Curlybars::Error::Render.new('nesting_too_deep', message, hbs.position(#{position.line_number}, #{position.line_offset}))
              end
              buffer = ActiveSupport::SafeBuffer.new
              #{compiled_items}
              buffer
            end
          end.exec(contexts, hbs)
        RUBY
      end
    end
  end
end
