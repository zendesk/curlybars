require 'curlybars/error/base'

module Curlybars::Error
  class Parse < Curlybars::Error::Base
    def initialize(source, exception)
      line_number = exception.current.position.line_number
      line_offset = exception.current.position.line_offset
      length = exception.current.position.length

      error_line = source.split("\n")[line_number - 1]
      before_error = error_line.first(line_offset).last(10)
      after_error = error_line[line_offset + length..-1].first(10)
      error = error_line.slice(line_offset, length)

      details = [before_error, error, after_error]
      message = ".. %s `%s` %s .. is not permitted in this context" % details
      super('parse', message, exception.current.position)
    end
  end
end
