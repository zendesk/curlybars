require 'curlybars/error/base'

module Curlybars
  module Error
    class Parse < Curlybars::Error::Base
      def initialize(source, exception)
        position = exception.current.position

        if exception.current.type == :EOS
          message = "A block helper hasn't been closed properly"
          position = EOSPosition.new(source)
        else
          line_number = position.line_number
          line_offset = position.line_offset
          length = exception.current.position.length

          error_line = source.split("\n")[line_number - 1]
          before_error = error_line.first(line_offset).last(10)
          after_error = error_line[line_offset + length..-1].first(10)
          error = error_line.slice(line_offset, length)

          details = [before_error, error, after_error]
          message = ".. %s `%s` %s .. is not permitted in this context" % details
        end

        super('parse', message, position)
      end
    end

    class EOSPosition
      attr_reader :line_number, :line_offset, :length, :file_name

      def initialize(source)
        @line_number = source.count("\n") + 1
        @line_offset = 0
        @length = source.rpartition("\n").last.length
        @file_name = nil
      end
    end
  end
end
