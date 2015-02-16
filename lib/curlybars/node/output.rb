module Curlybars
  module Node
    Output = Struct.new(:expression) do
      def compile
        <<-RUBY
          ActiveSupport::SafeBuffer.new(#{expression.compile})
        RUBY
      end
    end
  end
end
