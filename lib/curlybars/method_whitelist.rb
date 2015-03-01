module Curlybars
  module MethodWhitelist
    def allow_methods(*methods)
      define_method(:allowed_methods) do
        defined?(super) ? super() + methods : methods
      end

      define_method(:allows_method?) do |method|
        allowed_methods.include?(method)
      end
    end

    def self.extended(base)
      # define a default of no method allowed
      base.allow_methods()
    end
  end
end
