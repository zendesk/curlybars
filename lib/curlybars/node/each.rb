module Curlybars
  module Node
    Each = Struct.new(:path, :template) do
      def compile
        <<-RUBY
          buffer = ActiveSupport::SafeBuffer.new
          #{path.compile}.call.each do
            buffer.safe_concat(#{template.compile})
          end
          buffer
        RUBY
      end
    end
  end
end
