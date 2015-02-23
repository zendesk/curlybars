module Curlybars
  module Node
    Template = Struct.new(:items) do
      def compile
        compiled_items = (items || []).map(&:compile).join("\n")

        <<-RUBY
          Module.new do
            def self.exec(contexts, hbs)
              raise "Nesting too deep" unless contexts.length < 10
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
