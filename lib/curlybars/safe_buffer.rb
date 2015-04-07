module Curlybars
  class SafeBuffer < SimpleDelegator
    def initialize(*args)
      super(ActiveSupport::SafeBuffer.new(*args))
    end

    def safe_concat(buffer)
      unless (length + buffer.length) < Curlybars.configuration.output_limit
        message = "Output too long (> %s bytes)" % Curlybars.configuration.output_limit
        raise Curlybars::Error::Render.new('output_too_long', message, nil)
      end
      super
    end
  end
end
