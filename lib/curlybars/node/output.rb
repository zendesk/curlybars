module Curlybars
  module Node
    Output = Struct.new(:value) do
      def compile
        <<-RUBY
          buffer.safe_concat(rendering.cached_call(#{value.compile}).to_s)
        RUBY
      end

      def validate(branches)
        value.validate(branches)
      end
    end
  end
end
