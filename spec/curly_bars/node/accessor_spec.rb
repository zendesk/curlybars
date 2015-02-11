describe CurlyBars::Node::Accessor do
  it "compiles correctly" do
    node = CurlyBars::Node::Accessor.new("foo.bar")

    ruby_code =<<-RUBY.strip_heredoc
      begin
        "foo.bar".split(/\\./).inject(contexts.last) do |memo, m|
          if memo.respond_to?(m.to_sym)
            memo.public_send(m.to_sym)
          else
            raise "Template error: context doesn't implement: " << m
          end
        end
      end
    RUBY

    expect(node.compile).to eq(ruby_code)
  end
end
