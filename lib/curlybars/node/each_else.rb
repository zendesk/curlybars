module Curlybars
  module Node
    EachElse = Struct.new(:path, :each_template, :else_template) do
      def compile
        <<-RUBY
          collection = #{path.compile}
          if collection.any?
            buffer = ActiveSupport::SafeBuffer.new
            collection.each do
              buffer.safe_concat(#{each_template.compile})
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
