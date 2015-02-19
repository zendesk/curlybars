module Curlybars
  module Node
    Root = Struct.new(:template) do
      def compile
        <<-RUBY
          contexts = [presenter]
          hbs = #{self.class.hbs}.new(contexts)
          #{template.compile}
        RUBY
      end

      def self.hbs
        <<-RUBY
          Struct.new(:contexts) do
            def to_bool(condition)
              condition != false &&
              condition != [] &&
              condition != 0 &&
              condition != '' &&
              condition != nil
            end

            def path(path)
              chain = path.split(/\\./)
              method_to_return = chain.pop

              resolved = chain.inject(contexts.last) do |context, meth|
                raise_if_not_traversable(context, meth)
                context.public_send(meth)
              end

              raise_if_not_traversable(resolved, method_to_return)
              resolved.method(method_to_return.to_sym)
            end

            private

            def raise_if_not_traversable(context, meth)
              accessor = meth.to_sym

              context_allows_method = context.class.allows_method?(accessor)
              context_responds_to_method = context.respond_to?(accessor)

              unless context_allows_method && context_responds_to_method
                raise context.class.to_s + " doesn't allow `" + meth + "`"
              end
            end
          end
        RUBY
      end
    end
  end
end
