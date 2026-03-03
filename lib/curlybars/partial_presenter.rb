module Curlybars
  class PartialPresenter
    extend MethodWhitelist

    def initialize(_context, data = {})
      @_data = data.symbolize_keys
      @_data.each do |key, value|
        define_singleton_method(key) { value }
      end
    end

    # Subclasses that call allow_methods get their allowed_methods via super,
    # which includes these dynamic data keys.
    def allowed_methods
      @_data.keys
    end

    def allows_method?(method)
      @_data.key?(method.to_sym)
    end
  end
end
