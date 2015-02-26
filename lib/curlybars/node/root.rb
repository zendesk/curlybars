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
            def check_context_is_presenter(context, path, position)
              unless context.class.respond_to? :allows_method?
                message = "`" + path + "` is not a context type object"
                raise Curlybars::Error::Render.new('context_is_not_a_presenter', message, position)
              end
            end

            def check_context_is_array_of_presenters(collection, path, position)
              array_of_presenters = collection.respond_to?(:each) && 
                collection.all? { |presenter| presenter.class.respond_to? :allows_method? }
              unless array_of_presenters
                message = "`" + path + "` is not an array of presenters"
                raise Curlybars::Error::Render.new('context_is_not_an_array_of_presenters', message, position)
              end
            end

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
                message = "`" +  meth + "` is not available. "
                message += "Add `allow_methods :" + meth + "` to " + context.class.to_s + " to allow this path."
                raise Curlybars::Error::Render.new('path_not_allowed', message, position)
              end
            end
          end
        RUBY
      end
    end
  end
end
