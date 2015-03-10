module Curlybars
  module Node
    Item = Struct.new(:item) do
      def compile
        <<-RUBY
          Module.new do
            def self.exec(contexts, rendering, variables, buffer)
              #{item.compile}
            end
          end.exec(contexts, rendering, variables, buffer)
        RUBY
      end

      def validate(branches)
        catch(:skip_item_validation) do
          item.validate(branches)
        end
      end
    end
  end
end
