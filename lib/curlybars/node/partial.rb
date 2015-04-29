module Curlybars
  module Node
    Partial = Struct.new(:path) do
      def compile
        <<-RUBY
          buffer.safe_concat(rendering.cached_call(#{path.compile}).to_s)
        RUBY
      end

      def validate(branches)
        path.validate(branches, check_type: :partial)
      end
    end
  end
end
