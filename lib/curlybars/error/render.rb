require 'curlybars/error/base'

module Curlybars::Error
  class Render < Curlybars::Error::Base
    def initialize(message, position)
      super
    end
  end
end
