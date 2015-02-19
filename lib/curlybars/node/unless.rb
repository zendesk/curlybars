module Curlybars
  module Node
    Unless = Struct.new(:expression, :template) do
      def compile
        <<-RUBY
          buffer = ActiveSupport::SafeBuffer.new
          unless hbs.to_bool(#{expression.compile}.call)
            buffer.safe_concat(#{template.compile})
          end
          buffer
        RUBY
      end
    end
  end
end