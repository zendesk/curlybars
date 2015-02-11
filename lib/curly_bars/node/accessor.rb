module CurlyBars
  module Node
    class Accessor
      attr_reader :methods_chain

      def initialize(methods_chain)
        @methods_chain = methods_chain
      end

      def compile
<<-RUBY
begin
  "#{methods_chain}".split(/\\./).inject(contexts.last) do |memo, m|
    if memo.respond_to?(m.to_sym)
      memo.public_send(m.to_sym)
    else
      raise "Template error: context doesn't implement: " << m
    end
  end
end
RUBY
      end
    end
  end
end
