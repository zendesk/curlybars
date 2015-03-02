module Curlybars
  module Node
    Path = Struct.new(:path, :position) do
      def compile
        <<-RUBY
        rendering.path(
            #{path.inspect},
            rendering.position(#{position.line_number}, #{position.line_offset})
          )
        RUBY
      end
    end
  end
end
