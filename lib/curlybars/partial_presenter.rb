module Curlybars
  class PartialPresenter
    extend MethodWhitelist

    def initialize(_context, data = {})
      @_data = data.symbolize_keys
    end

    def allows_method?(method)
      @_data.key?(method.to_sym)
    end

    def method_missing(method, *args)
      return @_data[method.to_sym] if @_data.key?(method.to_sym)

      super
    end

    def respond_to_missing?(method, include_private = false)
      @_data.key?(method.to_sym) || super
    end
  end
end
