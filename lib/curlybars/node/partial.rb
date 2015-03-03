module Curlybars
  module Node
    Partial = Struct.new(:path) do
      def compile
        <<-RUBY
          buffer.safe_concat(#{path.compile}.call.to_s)
        RUBY
      end

      def validate(dependency_tree)
        path.validate(dependency_tree, check_type: :leaf)
      end
    end
  end
end
