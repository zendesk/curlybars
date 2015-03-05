module Curlybars
  module Node
    class Empty
      def compile
        ''.inspect
      end

      def validate(base_tree)
        # Nothing to validate here.
      end
    end
  end
end
