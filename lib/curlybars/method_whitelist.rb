module Curlybars
  module MethodWhitelist
    def allow_methods(*methods_without_type, **methods_with_type, &contextual_block)
      methods_with_type_validator = lambda do |methods_to_validate|
        methods_to_validate.each do |(method_name, type)|
          if type.is_a?(Array)
            next if generic_or_collection_helper?(type)

            if type.size != 1 || !type.first.respond_to?(:dependency_tree)
              raise "Invalid allowed method syntax for `#{method_name}`. Collections must be of one presenter class"
            end
          end
        end
      end

      methods_with_type_validator.call(methods_with_type)

      define_method(:allowed_methods) do
        @method_whitelist_allowed_methods ||= begin
          methods_list = methods_without_type + methods_with_type.keys

          # Adds methods to the list of allowed methods
          method_adder = lambda do |*more_methods, **more_methods_with_type|
            methods_with_type_validator.call(more_methods_with_type)

            methods_list += more_methods
            methods_list += more_methods_with_type.keys
          end

          contextual_block&.call(self, method_adder)

          defined?(super) ? super() + methods_list : methods_list
        end
      end

      define_singleton_method(:methods_schema) do |context = nil|
        all_methods_without_type = methods_without_type
        all_methods_with_type = methods_with_type

        # Adds methods to the schema
        schema_adder = lambda do |*more_methods_without_type, **more_methods_with_type|
          methods_with_type_validator.call(more_methods_with_type)

          all_methods_without_type += more_methods_without_type
          all_methods_with_type = all_methods_with_type.merge(more_methods_with_type)
        end

        contextual_block&.call(context, schema_adder)

        schema = all_methods_without_type.each_with_object({}) do |method, memo|
          memo[method] = nil
        end

        methods_with_type_resolved = all_methods_with_type.transform_values do |type|
          if type.respond_to?(:call)
            type.call(context)
          else
            type
          end
        end

        schema.merge!(methods_with_type_resolved)

        # Inheritance
        schema.merge!(super(context)) if defined?(super)

        # Included modules
        included_modules.each do |mod|
          next unless mod.respond_to?(:methods_schema)

          schema.merge!(mod.methods_schema(context))
        end

        schema
      end

      define_singleton_method(:dependency_tree) do |context = nil|
        methods_schema(context).each_with_object({}) do |method_with_type, memo|
          method_name = method_with_type.first
          type = method_with_type.last

          memo[method_name] = if type.respond_to?(:dependency_tree)
            type.dependency_tree(context)
          elsif type.is_a?(Array)
            if type.first == :helper
              if type.last.is_a?(Array)
                [:helper, [type.last.first.dependency_tree(context)]]
              else
                [:helper, type.last.dependency_tree(context)]
              end
            else
              [type.first.dependency_tree(context)]
            end
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

    private

    def generic_or_collection_helper?(type)
      return false unless type.size == 2
      return false unless type.first == :helper
      return true if type.last.respond_to?(:dependency_tree)
      return false unless type.last.is_a?(Array) && type.last.size == 1

      type.last.first.respond_to?(:dependency_tree)
    end
  end
end
