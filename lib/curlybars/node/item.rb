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

      def validate(dependency_tree)
        item.validate(dependency_tree)
      end
    end
  end
end
