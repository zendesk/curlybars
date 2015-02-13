module CurlyBars
  module Node
    Template = Struct.new(:items) do
      def compile
        <<-RUBY
          Module.new do
            def self.exec(contexts)
              buffer = ActiveSupport::SafeBuffer.new
              #{items.map(&:compile).join("\n")}
              buffer
            end
          end.exec(contexts)
        RUBY
      end
    end
  end
end
