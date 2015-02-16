describe Curlybars::Node::Path do
  it "compiles correctly" do
    node = Curlybars::Node::Path.new("foo.bar")

    ruby_code =<<-RUBY.strip_heredoc
      begin
        "foo.bar".split(/\\./).inject(contexts.last) do |memo, m|
          if memo.respond_to?(m.to_sym)
            memo.public_send(m.to_sym)
          else
            raise "Template error: context " + memo.class.to_s + " doesn't implement: " << m
          end
        end
      end
    RUBY

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
