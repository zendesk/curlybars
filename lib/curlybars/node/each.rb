module Curlybars
  module Node
    Each = Struct.new(:path, :template) do
      def compile
        <<-RUBY
          #{path.compile}.call.each do |presenter|
            contexts << presenter
            begin
              buffer.safe_concat(#{template.compile})
            ensure
              contexts.pop
            end
          end
        RUBY
      end
    end
  end
end
