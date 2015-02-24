require 'curlybars/error/base'

module Curlybars::Error
  class Lex < Curlybars::Error::Base
    def initialize(source, file_name, exception)
      not_consumed_source = source[exception.stream_offset..-1]
      invalid_token = not_consumed_source.first
      rest_of_the_line = not_consumed_source.split("\n").first
      details = [invalid_token, rest_of_the_line]
      message = "Invalid token: `%s` in `%s`" % details
      position = TemplatePosition.new(
        exception.line_number,
        exception.line_offset,
        file_name
      )
      super(message, position)
    end

    private

    TemplatePosition = Struct.new(:line_number, :line_offset, :file_name)
  end
end
