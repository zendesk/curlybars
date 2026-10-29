module Curlybars
  module Processor
    module TokenFactory
      def create_token(type, value, position)
        Curlybars::Token.new(type, value, position)
      end
    end
  end
end
