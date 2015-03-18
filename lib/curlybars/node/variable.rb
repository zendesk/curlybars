module Curlybars
  module Node
    Variable = Struct.new(:variable) do
      def compile
        <<-RUBY
          -> { rendering.variable(#{variable.inspect}) }
        RUBY
      end

      def validate(branches)
        # Nothing to validate here.
      end
    end
  end
end
