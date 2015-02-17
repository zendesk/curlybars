module Curlybars
  module Node
    EachElse = Struct.new(:path, :each_template, :else_template) do
      def compile
        <<-RUBY
          collection = #{path.compile}.call
          if collection.any?
            buffer = ActiveSupport::SafeBuffer.new
            collection.each do |presenter|
              contexts << presenter
              begin
                buffer.safe_concat(#{each_template.compile})
              ensure
                contexts.pop
              end
            end
            buffer
          else
            #{else_template.compile}
          end
        RUBY
      end
    end
  end
end
