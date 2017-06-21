require 'curlybars/error/base'

module Curlybars
  module Error
    class Validate < Curlybars::Error::Base
      def initialize(id, message, rltk_position, offset_adjustment = 0, **metadata)
        position = Curlybars::Position.new(
          rltk_position.file_name,
          rltk_position.line_number,
          rltk_position.line_offset + offset_adjustment,
          rltk_position.length - offset_adjustment
        )

        super('validate.%s' % id, message, position, metadata)
      end
    end
  end
end
