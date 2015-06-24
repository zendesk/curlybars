module Curlybars
  class SafeBuffer < ActiveSupport::SafeBuffer
    def concat(buffer)
      if (length + buffer.length) > Curlybars.configuration.output_limit
        message = "Output too long (> %s bytes)" % Curlybars.configuration.output_limit
        raise Curlybars::Error::Render.new('output_too_long', message, nil)
      end
      super
    end
  end
end
