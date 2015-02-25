module Curlybars::Error
  class Base < StandardError
    def initialize(message, position)
      super(message)
      return if position.file_name.nil?
      location = "%s:%d:%d" % [position.file_name, position.line_number, position.line_offset]
      set_backtrace([location])
    end
  end
end
