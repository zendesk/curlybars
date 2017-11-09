module Curlybars
  module Node
    WithElse = Struct.new(:path, :with_template, :else_template, :position) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          compiled_path = rendering.cached_call(#{path.compile})

          if rendering.to_bool(compiled_path)
            position = rendering.position(#{position.line_number}, #{position.line_offset})
            rendering.check_context_is_presenter(compiled_path, #{path.path.inspect}, position)

            contexts.push(compiled_path)
            begin
              #{with_template.compile}
            ensure
              contexts.pop
            end
          else
            #{else_template.compile}
          end
        RUBY
      end

      def validate(branches)
        sub_tree = path.resolve_and_check!(branches, check_type: :presenter)
        with_template_errors = begin
          branches.push(sub_tree)
          with_template.validate(branches)
        ensure
          branches.pop
        end

        else_template_errors = else_template.validate(branches)

        [
          with_template_errors,
          else_template_errors
        ]
      rescue Curlybars::Error::Validate => path_error
        path_error
      end

      def cache_key
        [
          path,
          with_template,
          else_template
        ].map(&:cache_key).push(self.class.name).join("/")
      end
    end
  end
end
