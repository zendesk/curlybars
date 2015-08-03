require 'curlybars/error/base'

module Curlybars
  module Error
    class Validate < Curlybars::Error::Base
      def initialize(id, message, position, **metadata)
        super('validate.%s' % id, message, position, metadata)
      end
    end
  end
end
