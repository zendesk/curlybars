module Curlybars
  module Node
    With = Struct.new(:path, :template, :position) do
      def compile
        <<-RUBY
          compiled_path = #{path.compile}.call
          return if compiled_path.nil?

          position = rendering.position(#{position.line_number}, #{position.line_offset})
          rendering.check_context_is_presenter(compiled_path, #{path.path.inspect}, position)

          contexts.push(compiled_path)
          begin
            buffer.safe_concat(#{template.compile})
          ensure
            contexts.pop
          end
        RUBY
      end

      def validate(trees)
        sub_tree = path.resolve_and_check!(trees, check_type: :presenter)
        begin
          trees.push(sub_tree)
          template.validate(trees)
        ensure
          trees.pop
        end
      rescue Curlybars::Error::Validate => path_error
        path_error
      end
    end
  end
end
