module Curlybars
  module Node
    Path = Struct.new(:path) do
      def compile
        <<-RUBY
          hbs.path(#{path.inspect})
        RUBY
      end
    end
  end
end
