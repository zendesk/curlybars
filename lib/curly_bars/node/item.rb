module CurlyBars
  module Node
    Item = Struct.new(:item) do
      def compile
        <<-RUBY
          Module.new do
            def self.exec(contexts)
              #{item.compile}
            end
          end.exec(contexts)
        RUBY
      end
    end
  end
end
