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
        methods.inject({}) do |memo, method|
          memo[method] = nil
          memo
        end.merge(methods_with_type)
      end

      define_singleton_method(:dependency_tree) do
        methods_schema.inject({}) do |memo, method_with_type|
          method_name = method_with_type.first
          type = method_with_type.last

          if type.respond_to?(:dependency_tree)
            memo[method_name] = type.dependency_tree
          elsif type.is_a?(Array)
            memo[method_name] = [type.first.dependency_tree]
          else
            memo[method_name] = type
          end

          memo
        end
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
