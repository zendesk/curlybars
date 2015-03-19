module Curlybars
  module Node
    EachElse = Struct.new(:path, :each_template, :else_template, :position) do
      def compile
        <<-RUBY
          compiled_path = rendering.cached_call(#{path.compile})

          if rendering.to_bool(compiled_path)
            #{Each.new(path, each_template, position).compile}
          else
            buffer.safe_concat(#{else_template.compile})
          end
        RUBY
      end

      def validate(branches)
        [
          Each.new(path, each_template, position).validate(branches),
          else_template.validate(branches)
        ]
      rescue Curlybars::Error::Validate => path_error
        path_error
      end
    end
  end
end
