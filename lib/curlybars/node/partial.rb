module Curlybars
  module Node
    Partial = Struct.new(:path) do
      def compile
        <<-RUBY
          buffer.safe_concat(#{path.compile}.call)
        RUBY
      end
    end
  end
end
