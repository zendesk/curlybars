module Curlybars
  module Node
    Item = Struct.new(:item) do
      def compile
        <<-RUBY
          Module.new do
            def self.exec(contexts, rendering, buffer)
              #{item.compile}
            end
          end.exec(contexts, rendering, buffer)
        RUBY
      end

      def validate(trees)
        catch(:skip_item_validation) do
          item.validate(trees)
        end
      end
    end
  end
end
