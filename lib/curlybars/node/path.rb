module Curlybars
  module Node
    Path = Struct.new(:path, :position) do
      def compile
        <<-RUBY
          hbs.path(
            #{path.inspect},
            hbs.position(#{position.line_number}, #{position.line_offset})
          )
        RUBY
      end
    end
  end
end
