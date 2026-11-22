# frozen_string_literal: true

module Curlybars
  module Node
    # Turns the code of nodes that need their own local variable scope into
    # methods on a module, which the root node creates once per render.
    #
    # Like the `def` in the old `::Module.new do def self.exec ... end end`
    # wrapper, a method can't see the locals of the code that calls it, so
    # nested nodes can't overwrite each other's locals. Unlike that wrapper,
    # the methods are defined once per render, not every time a node runs.
    module CompiledMethods
      KEY = :__curlybars_compiled_methods

      # Collects the methods defined by nodes compiled in the block.
      #
      # Returns the block's result and the Ruby code defining the methods.
      def self.collect
        previous = Thread.current[KEY]
        definitions = Thread.current[KEY] = []
        result = yield
        [result, definitions.join("\n")]
      ensure
        Thread.current[KEY] = previous
      end

      # Adds a method with the given parameters and body to the module.
      #
      # Returns the Ruby code that calls the method.
      def self.define(kind, parameters, body)
        definitions = Thread.current[KEY]
        name = "#{kind}_#{definitions.size + 1}"
        definitions << <<-RUBY
          def self.#{name}(#{parameters})
            #{body}
          end
        RUBY
        "#{name}(#{parameters})"
      end
    end
  end
end
