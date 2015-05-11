module Curlybars::Error
  class Base < StandardError
    attr_reader :id, :position, :metadata

    def initialize(id, message, position, metadata = {})
      super(message)
      @id = id
      @position = position
      @metadata = metadata
      return if position.nil?
      return if position.file_name.nil?
      location = "%s:%d:%d" % [position.file_name, position.line_number, position.line_offset]
      set_backtrace([location])
    end
  end
end
