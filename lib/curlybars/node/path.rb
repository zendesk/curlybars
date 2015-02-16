module Curlybars
  module Node
    Path = Struct.new(:path) do
      def compile
        <<-RUBY
          begin
            chain = "#{path}".split(/\\./)
            method_to_return = chain.pop
            resolved = chain.inject(contexts.last) do |memo, m|
              unless memo.class.allows_method?(m.to_sym)
                raise "Template error: context " + memo.class.to_s + " doesn't implement: " << m
              end
              memo.public_send(m.to_sym)
            end
            unless resolved.class.allows_method?(method_to_return.to_sym)
              raise "Template error: context " + resolved.class.to_s + " doesn't implement: " << method_to_return
            end
            resolved.method(method_to_return.to_sym)
          end
        RUBY
      end
    end
  end
end
