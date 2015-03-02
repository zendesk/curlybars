module Curlybars
  module Node
    Each = Struct.new(:path, :template, :position) do
      def compile
        <<-RUBY
          compiled_path = #{path.compile}.call

          position = rendering.position(#{position.line_number}, #{position.line_offset})
          rendering.check_context_is_array_of_presenters(compiled_path, #{path.path.inspect}, position)

          compiled_path.each do |presenter|
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
