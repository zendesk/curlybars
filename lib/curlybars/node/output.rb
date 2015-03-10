module Curlybars
  module Node
    Output = Struct.new(:value) do
      def compile
        <<-RUBY
          buffer.safe_concat(#{value.compile}.call.to_s)
        RUBY
      end

      def validate(branches)
        value.validate(branches)
      end
    end
  end
end
