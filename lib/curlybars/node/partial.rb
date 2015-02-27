module Curlybars
  module Node
    Partial = Struct.new(:path) do
      def compile
        <<-RUBY
          buffer.safe_concat(#{path.compile}.call.to_s)
        RUBY
      end
    end
  end
end
