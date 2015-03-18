module Curlybars
  module Node
    Variable = Struct.new(:variable, :position) do
      def compile
        <<-RUBY
          -> {
            position = rendering.position(
              #{position.line_number},
              #{position.line_offset}
            )
            rendering.variable(#{variable.inspect}, position)
          }
        RUBY
      end

      def validate(branches)
        # Nothing to validate here.
      end
    end
  end
end
