module Curlybars
  module MethodsWhitelisting
    def self.included(base)
      base.class_eval do
        class_attribute :allowed_methods
        self.allowed_methods = [].freeze

        def self.allow_methods(*methods)
          self.allowed_methods = methods
        end

        def self.allows_method?(method)
          self.allowed_methods.include?(method)
        end
      end
    end
  end
end
