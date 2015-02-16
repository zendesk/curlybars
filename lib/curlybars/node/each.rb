module Curlybars
  module Node
    Each = Struct.new(:expression, :template) do
      def compile
        <<-RUBY
          buffer = ActiveSupport::SafeBuffer.new
          #{expression.compile}.each do
            buffer.safe_concat(#{template.compile})
          end
          buffer
        RUBY
      end
    end
  end
end
