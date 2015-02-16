module Curlybars
  module Node
    String = Struct.new(:string) do
      def compile
        <<-RUBY
          ->() { ActiveSupport::SafeBuffer.new(#{string.inspect}) }
        RUBY
      end
    end
  end
end
