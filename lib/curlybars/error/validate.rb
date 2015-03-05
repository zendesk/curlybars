require 'curlybars/error/base'

module Curlybars::Error
  class Validate < Curlybars::Error::Base
    def initialize(id, message, position)
      super('validate.%s' % id, message, position)
    end
  end
end
