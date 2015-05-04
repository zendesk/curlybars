module Curlybars
  module Processor
    module TokenFactory
      def create_token(type, value, position)
        RLTK::Token.new(type, value, position)
      end
    end
  end
end
