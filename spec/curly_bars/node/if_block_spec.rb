describe CurlyBars::Node::IfBlock do
  it "compiles correctly" do
    ruby_code =<<-RUBY.strip_heredoc
      if valid
        foo
      end
    RUBY

    expression = "valid"
    template = ["foo"]
    node = CurlyBars::Node::IfBlock.new(expression, template)

    expect(node.compile).to eq(ruby_code)
  end
end
