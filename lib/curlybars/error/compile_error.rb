module Curlybars::Error
  class CompileError < StandardError
    def initialize(root, message, exception, template)
      super(message)
      source = root.join(template.inspect).to_s
      location = "%s:%d:%d" % [source, exception.line_number, exception.line_offset]
      set_backtrace([location])
    end
  end
end
