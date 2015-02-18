module Curlybars
  module Node
    Item = Struct.new(:item) do
      def compile
        <<-RUBY
          Module.new do
            def self.exec(contexts, hbs)
              #{item.compile}
            end
          end.exec(contexts, hbs)
        RUBY
      end
    end
  end
end
