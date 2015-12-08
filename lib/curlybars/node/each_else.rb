module Curlybars
  module Node
    EachElse = Struct.new(:path, :each_template, :else_template, :position) do
      def compile
        <<-RUBY
          collection = rendering.cached_call(#{path.compile})

          if rendering.to_bool(collection)
            position = rendering.position(#{position.line_number}, #{position.line_offset})

            collection = rendering.coerce_to_hash!(collection, #{path.path.inspect}, position)
            collection.each.with_index.map do |key_and_presenter, index|
              rendering.check_timeout!
              begin
                contexts.push(key_and_presenter[1])
                variables.push({
                  index: index,
                  key: key_and_presenter[0],
                  first: index == 0,
                  last: index == (collection.length - 1),
                })
                #{each_template.compile}
              ensure
                variables.pop
                contexts.pop
              end
            end
          else
            #{else_template.compile}
          end
        RUBY
      end

      def validate(branches)
        resolved = path.resolve_and_check!(branches, check_type: :presenter_collection)
        sub_tree = resolved.first

        each_template_errors = begin
          branches.push(sub_tree)
          each_template.validate(branches)
        ensure
          branches.pop
        end

        else_template_errors = else_template.validate(branches)

        [
          each_template_errors,
          else_template_errors
        ]
      rescue Curlybars::Error::Validate => path_error
        path_error
      end
    end
  end
end
