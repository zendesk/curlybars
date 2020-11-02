module Curlybars
  module Node
    EachElse = Struct.new(:path, :each_template, :else_template, :position) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          collection = rendering.cached_call(#{collection_path.compile})

          if rendering.to_bool(collection)
            position = rendering.position(#{position.line_number}, #{position.line_offset})
            template_cache_key = '#{each_template.cache_key}'

            collection = rendering.coerce_to_hash!(collection, #{collection_path.path.inspect}, position)
            collection.each.with_index.map do |key_and_presenter, index|
              rendering.check_timeout!
              rendering.optional_presenter_cache(key_and_presenter[1], template_cache_key, buffer) do |buffer|
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
            end
          else
            #{else_template.compile}
          end
        RUBY
      end

      def validate(branches)
        each_template_errors = begin
          branches.push(resolve_sub_tree(branches))
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

      def resolve_sub_tree(branches)
        resolved = collection_path.resolve_and_check!(branches, check_type: :collectionlike)

        return resolved.first unless resolved.first == :helper
        return resolved.last.first unless resolved.last.first == {}

        resolved = Curlybars::TypeInferrer.infer_from_node(path, branches.inject({}, :merge))
        resolved.first
      end

      def collection_path
        path.subexpression? ? path.helper : path
      end

      def cache_key
        [
          path,
          each_template,
          else_template
        ].map(&:cache_key).push(self.class.name).join("/")
      end
    end
  end
end
