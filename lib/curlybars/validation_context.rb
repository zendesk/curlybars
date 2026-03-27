module Curlybars
  class ValidationContext
    attr_reader :partial_resolver, :depth

    def initialize(partial_resolver: nil, depth: 0)
      @partial_resolver = partial_resolver
      @depth = depth
    end

    def valid?
      depth < Curlybars.configuration.partial_nesting_limit
    end

    def increment_depth
      self.class.new(partial_resolver: partial_resolver, depth: depth + 1)
    end
  end
end
