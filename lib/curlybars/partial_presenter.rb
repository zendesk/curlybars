module Curlybars
  class PartialPresenter
    extend MethodWhitelist

    def initialize(_context, data = {})
      @_safe_keys = Set.new
      data.symbolize_keys.each do |key, value|
        next if respond_to?(key, true)

        define_singleton_method(key) { value }
        @_safe_keys.add(key)
      end
      @_safe_keys.freeze
    end

    # Subclasses that call allow_methods get their allowed_methods via super,
    # which includes these dynamic data keys.
    def allowed_methods
      @_safe_keys.to_a
    end

    def allows_method?(method)
      @_safe_keys.include?(method.to_sym)
    end
  end
end
