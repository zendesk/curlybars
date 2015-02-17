module Curlybars
  module Node
    Partial = Struct.new(:path) do
      def compile
        <<-RUBY
          #{path.compile}.call
        RUBY
      end
    end
  end
end
