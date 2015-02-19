module Curlybars
  module Node
    Root = Struct.new(:template) do
      def compile
        <<-RUBY
          contexts = [presenter]
          hbs = #{hbs}.new(contexts)
          ActiveSupport::SafeBuffer.new(#{template.compile})
        RUBY
      end

      private

      def hbs
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
              resolved = chain.inject(contexts.last) do |memo, m|
                if !memo.class.allows_method?(m.to_sym) || !memo.respond_to?(m.to_sym)
                  raise "Template error: context " + memo.class.to_s + " doesn't implement: " << m
                end
                memo.public_send(m.to_sym)
              end
              if !resolved.class.allows_method?(method_to_return.to_sym) || !resolved.respond_to?(method_to_return.to_sym)
                raise "Template error: context " + resolved.class.to_s + " doesn't implement: " << method_to_return
              end
              resolved.method(method_to_return.to_sym)
            end
          end
        RUBY
      end
    end
  end
end
