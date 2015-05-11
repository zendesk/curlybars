require 'curlybars/error/base'

module Curlybars::Error
  class Render < Curlybars::Error::Base
    def initialize(id, message, position, **metadata)
      super('render.%s' % id, message, position, metadata)
    end
  end
end
