describe CurlyBars::Node::Output do
  it "compiles correctly" do
    expression = double("expression", compile: 'foo')
    node = CurlyBars::Node::Output.new(expression)

    ruby_code = "buffer << foo\n"

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
