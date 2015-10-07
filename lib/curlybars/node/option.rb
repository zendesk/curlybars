module Curlybars
  module Node
    Option = Struct.new(:key, :expression) do
      def compile
        <<-RUBY
          { #{key.to_s.inspect} => rendering.cached_call(#{expression.compile}) }
        RUBY
      end

      def validate(branches)
        expression.validate_as_value(branches)
      end
    end
  end
end
