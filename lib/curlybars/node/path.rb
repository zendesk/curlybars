module Curlybars
  module Node
    Path = Struct.new(:path) do
      def compile
        <<-RUBY
          begin
            chain = "#{path}".split(/\\./)
            method_to_return = chain.pop
            resolved = chain.inject(contexts.last) do |memo, m|
              if memo.respond_to?(m.to_sym)
                memo.public_send(m.to_sym)
              else
                raise "Template error: context " + memo.class.to_s + " doesn't implement: " << m
              end
            end
            if resolved.respond_to?(m.to_sym)
              resolved.method(method_to_return.to_sym)
            end
          end
        RUBY
      end
    end
  end
end
