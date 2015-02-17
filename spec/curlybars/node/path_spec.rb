describe Curlybars::Node::Path do
  it "compiles correctly" do
    node = Curlybars::Node::Path.new("foo.bar")

    ruby_code =<<-RUBY.strip_heredoc
      begin
        chain = "foo.bar".split(/\\./)
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
    RUBY

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
