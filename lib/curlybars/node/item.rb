module Curlybars
  module Node
    Item = Struct.new(:item) do
      def compile
        <<-RUBY
          Module.new do
            def self.exec(contexts, hbs, buffer)
              #{item.compile}
            end
          end.exec(contexts, hbs, buffer)
        RUBY
      end
    end
  end
end
