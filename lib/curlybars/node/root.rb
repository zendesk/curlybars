module Curlybars
  module Node
    Root = Struct.new(:template, :position) do
      def compile
        <<-RUBY
          contexts = [presenter]
          hbs = #{self.class.hbs}.new(contexts, #{position.file_name.inspect})
          #{template.compile}
        RUBY
      end

      def self.hbs
        <<-RUBY
          Struct.new(:contexts, :file_name) do
            def to_bool(condition)
              condition != false &&
              condition != [] &&
              condition != 0 &&
              condition != '' &&
              condition != nil
            end

            def path(path, position)
              chain = path.split(/\\./)
              method_to_return = chain.pop

              resolved = chain.inject(contexts.last) do |context, meth|
                raise_if_not_traversable(context, meth, position)
                context.public_send(meth)
              end

              raise_if_not_traversable(resolved, method_to_return, position)
              resolved.method(method_to_return.to_sym)
            end

            def position(line_number, line_offset)
              Curlybars::Position.new(file_name, line_number, line_offset)
            end

            private

            def raise_if_not_traversable(context, meth, position)
              accessor = meth.to_sym

              context_allows_method = context.class.allows_method?(accessor)
              context_responds_to_method = context.respond_to?(accessor)

              unless context_allows_method && context_responds_to_method
                message = context.class.to_s + " doesn't allow `" + meth + "`"
                raise Curlybars::Error::Render.new(message, position)
              end
            end
          end
        RUBY
      end
    end
  end
end
