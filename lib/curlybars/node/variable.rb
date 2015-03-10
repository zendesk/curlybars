module Curlybars
  module Node
    Variable = Struct.new(:variable) do
      def compile
        <<-RUBY
          -> {
            path_split_by_slashes = #{variable.inspect}.split('/')
            backward_steps_on_variables = path_split_by_slashes.count - 1
            variables_position = variables.length - backward_steps_on_variables
            index = variables_position - 1
            variables[index][path_split_by_slashes.last.to_sym] unless index < 0
          }
        RUBY
      end

      def validate(branches)
        # Nothing to validate here.
      end
    end
  end
end
