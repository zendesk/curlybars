require 'curlybars/error/base'

module Curlybars::Error
  class Lex < Curlybars::Error::Base
    def initialize(source, file_name, exception)
      line_number = exception.line_number
      line_offset = exception.line_offset

      error_line = source.split("\n")[line_number-1]
      before_error = error_line.first(line_offset).last(10)
      after_error = error_line[line_offset+1..-1].first(10)
      error = error_line[line_offset]

      details = [before_error, error, after_error]
      message = ".. %s `%s` %s .. is not permitted symbol in this context" % details
      position = Curlybars::Position.new(file_name, line_number, line_offset)
      super('lex', message, position)
    end
  end
end
