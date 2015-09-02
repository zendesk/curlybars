module Curlybars
  module MethodWhitelist
    def allow_methods(*methods, **methods_with_type)
      methods_with_type.each do |method_with_type|
        method_name = method_with_type.first
        type = method_with_type.last

        if type.is_a?(Array)
          if type.size != 1 || !type.first.respond_to?(:dependency_tree)
            raise "Invalid allowed method syntax for `#{method_name}`. Collections must be of one presenter class"
          end
        end
      end

      define_method(:allowed_methods) do
        methods_list = methods + methods_with_type.keys
        defined?(super) ? super() + methods_list : methods_list
      end

      define_singleton_method(:methods_schema) do
        schema = methods.each_with_object({}) do |method, memo|
          memo[method] = nil
        end

        schema.merge!(methods_with_type)

        # Inheritance
        schema.merge!(super()) if defined?(super)

        # Included modules
        included_modules.each do |mod|
          next unless mod.respond_to?(:methods_schema)
          schema.merge!(mod.methods_schema)
        end

        schema
      end

      define_singleton_method(:dependency_tree) do |strict: false|
        methods_schema.each_with_object({}) do |method_with_type, memo|
          method_name = method_with_type.first
          type = method_with_type.last

          next if strict && type == :deprecated

          if type.respond_to?(:dependency_tree)
            memo[method_name] = type.dependency_tree(strict: strict)
          elsif type.is_a?(Array)
            memo[method_name] = [type.first.dependency_tree(strict: strict)]
          else
            memo[method_name] = type
          end
        end
      end

      define_method(:allows_method?) do |method|
        allowed_methods.include?(method)
      end
    end

    def self.extended(base)
      # define a default of no method allowed
      base.allow_methods
    end
  end
end
