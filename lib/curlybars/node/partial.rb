module Curlybars
  module Node
    Partial = Struct.new(:path) do
      def compile
        <<-RUBY
          buffer.safe_concat(#{path.compile}.call.to_s)
        RUBY
      end

      def validate(branches)
        path.validate(branches, check_type: :leaf)
      end
    end
  end
end
