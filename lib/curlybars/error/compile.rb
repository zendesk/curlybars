require 'curlybars/error/base'

module Curlybars::Error
  class Compile < Curlybars::Error::Base
    def initialize(message, position)
      super(message, position)
    end
  end
end
