module Curlybars
  module Node
    Each = Struct.new(:path, :template) do
      def compile
        <<-RUBY
          buffer = ActiveSupport::SafeBuffer.new
          #{path.compile}.call.each do |presenter|
            contexts << presenter
            begin
              buffer.safe_concat(#{template.compile})
            ensure
              contexts.pop
            end
          end
          buffer
        RUBY
      end
    end
  end
end
