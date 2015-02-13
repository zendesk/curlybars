describe CurlyBars::Node::IfBlock do
  it "compiles correctly" do
    ruby_code =<<-RUBY.strip_heredoc
      if true
        buffer.safe_concat(foo)
      end
    RUBY

    expression = double('expression', compile: true)
    template = double('template', compile: 'foo')
    node = CurlyBars::Node::IfBlock.new(expression, template)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
