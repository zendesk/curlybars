module Curlybars
  module MethodWhitelist
    def allow_methods(*methods, **methods_with_type)
      methods_with_type.each do |(method_name, type)|
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

      define_singleton_method(:methods_schema) do |*args|
        schema = methods.each_with_object({}) do |method, memo|
          memo[method] = nil
        end

        methods_with_type_resolved = methods_with_type.each_with_object({}) do |(method_name, type), memo|
          memo[method_name] = if type.respond_to?(:call)
            type.call(*args)
          else
            type
          end
        end

        schema.merge!(methods_with_type_resolved)

        # Inheritance
        schema.merge!(super(*args)) if defined?(super)

        # Included modules
        included_modules.each do |mod|
          next unless mod.respond_to?(:methods_schema)
          schema.merge!(mod.methods_schema(*args))
        end

        schema
      end

      define_singleton_method(:dependency_tree) do |*args|
        methods_schema(*args).each_with_object({}) do |method_with_type, memo|
          method_name = method_with_type.first
          type = method_with_type.last

          memo[method_name] = if type.respond_to?(:dependency_tree)
            type.dependency_tree(*args)
          elsif type.is_a?(Array)
            [type.first.dependency_tree(*args)]
          else
            type
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
