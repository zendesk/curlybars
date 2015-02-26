require 'curlybars/error/base'

module Curlybars::Error
  class Compile < Curlybars::Error::Base
    def initialize(id, message, position)
      super('compile.%s' % id, message, position)
    end
  end
end
