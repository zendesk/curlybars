module Curlybars
  module Node
    With = Struct.new(:path, :template, :position) do
      def compile
        <<-RUBY
          compiled_path = rendering.cached_call(#{path.compile})
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

      def validate(branches)
        sub_tree = path.resolve_and_check!(branches, check_type: :presenter)
        begin
          branches.push(sub_tree)
          template.validate(branches)
        ensure
          branches.pop
        end
      rescue Curlybars::Error::Validate => path_error
        path_error
      end
    end
  end
end
