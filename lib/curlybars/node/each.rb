module Curlybars
  module Node
    Each = Struct.new(:path, :template, :position) do
      def compile
        <<-RUBY
          collection = #{path.compile}.call
          return if collection.nil?

          position = rendering.position(#{position.line_number}, #{position.line_offset})
          rendering.check_context_is_array_of_presenters(collection, #{path.path.inspect}, position)

          collection.each_with_index do |presenter, index|
            begin
              contexts.push(presenter)
              variables.push({
                index: index,
                first: index == 0,
                last: index == (collection.length - 1),
              })
              buffer.safe_concat(#{template.compile})
            ensure
              variables.pop
              contexts.pop
            end
          end
        RUBY
      end

      def validate(branches)
        resolved = path.resolve_and_check!(branches, check_type: :presenter_collection)
        sub_tree = resolved.first
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
