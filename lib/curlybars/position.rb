module Curlybars
  Position = Struct.new(:file_name, :line_number, :line_offset, :length) do
    def initialize(file_name, line_number, line_offset, length = 0)
      super
    end
  end
end
