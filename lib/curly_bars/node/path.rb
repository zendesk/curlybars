module CurlyBars
  module Node
    class Path
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def compile
<<-RUBY
begin
  "#{path}".split(/\\./).inject(contexts.last) do |memo, m|
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
