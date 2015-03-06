module Curlybars
  module Node
    Each = Struct.new(:path, :template, :position) do
      def compile
        <<-RUBY
          compiled_path = #{path.compile}.call
          return if compiled_path.nil?

          position = rendering.position(#{position.line_number}, #{position.line_offset})
          rendering.check_context_is_array_of_presenters(compiled_path, #{path.path.inspect}, position)

          compiled_path.each do |presenter|
            contexts.push(presenter)
            begin
              buffer.safe_concat(#{template.compile})
            ensure
              contexts.pop
            end
          end
        RUBY
      end

      def validate(base_tree)
        resolved = path.resolve_and_check!(base_tree, check_type: :presenter_collection)
        sub_tree = resolved.first
        template.validate(sub_tree)
      rescue Curlybars::Error::Validate => path_error
        path_error
      end
    end
  end
end
