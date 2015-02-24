require 'curlybars/error/base'

module Curlybars::Error
  class Parse < Curlybars::Error::Base
    def initialize(source, exception)
      position = exception.current.position
      not_consumed_source = source[position.stream_offset..-1]
      invalid_occurrence = not_consumed_source.first(position.length)
      rest_of_the_line = not_consumed_source.split("\n").first
      details = [invalid_occurrence, rest_of_the_line]
      message = "Parsing error: `%s` in `%s` is not allowed" % details
      super(message, position)
    end
  end
end
