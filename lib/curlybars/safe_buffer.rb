# frozen_string_literal: true

module Curlybars
  class SafeBuffer < ActiveSupport::SafeBuffer
    def concat(buffer)
      if (bytesize + buffer.bytesize) > Curlybars.configuration.output_limit
        message = "Output too long (> %s bytes)" % Curlybars.configuration.output_limit
        raise Curlybars::Error::Render.new('output_too_long', message, nil)
      end
      super
    end
    alias_method :<<, :concat
  end
end
