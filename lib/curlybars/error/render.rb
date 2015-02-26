require 'curlybars/error/base'

module Curlybars::Error
  class Render < Curlybars::Error::Base
    def initialize(id, message, position)
      super('render.%s' % id, message, position)
    end
  end
end
