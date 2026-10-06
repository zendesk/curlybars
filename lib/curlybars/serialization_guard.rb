module Curlybars
  class SerializationGuard
    def initialize(budget:, depth_limit:)
      @budget = budget
      @depth_limit = depth_limit
      @accumulated = 0
      @depth = 0
    end

    def enter!
      @depth += 1
      return unless @depth > @depth_limit

      message = "Serialization nesting too deep (> #{@depth_limit})"
      raise Curlybars::Error::Render.new('nesting_too_deep', message, nil)
    end

    def leave!
      @depth -= 1
    end

    def measure(value)
      # Only String leaves are counted: deep-measuring every Hash/Array would
      # mean serializing twice. This under-counts raw hash/array fields; the
      # authoritative ceiling is still SafeBuffer#concat at the output node.
      return unless value.is_a?(String)

      @accumulated += value.bytesize
      return unless @accumulated > @budget

      message = "Output too long (> #{@budget} bytes)"
      raise Curlybars::Error::Render.new('output_too_long', message, nil)
    end
  end
end
