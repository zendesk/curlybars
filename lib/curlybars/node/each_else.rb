module Curlybars
  module Node
    EachElse = Struct.new(:path, :each_template, :else_template, :position) do
      def compile
        <<-RUBY
          compiled_path = #{path.compile}.call

          if rendering.to_bool(compiled_path)
            position = rendering.position(#{position.line_number}, #{position.line_offset})
            rendering.check_context_is_array_of_presenters(compiled_path, #{path.path.inspect}, position)

            compiled_path.each do |presenter|
              contexts.push(presenter)
              begin
                buffer.safe_concat(#{each_template.compile})
              ensure
                contexts.pop
              end
            end
          else
            buffer.safe_concat(#{else_template.compile})
          end
        RUBY
      end

      def validate(base_tree)
        resolved = path.resolve_and_check!(base_tree, check_type: :presenter_collection)
        sub_tree = resolved.first
        template_errors = begin
          branches.push(sub_tree)
          template.validate(branches)
        ensure
          branches.pop
        end
        [
          template_errors,
          else_template.validate(branches)
        ]
      rescue Curlybars::Error::Validate => path_error
        path_error
      end
    end
  end
end
