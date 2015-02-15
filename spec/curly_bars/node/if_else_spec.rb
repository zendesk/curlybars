describe CurlyBars::Node::IfElse do
  it "compiles correctly" do
    ruby_code =<<-RUBY.strip_heredoc
      if expression
        if_template
      else
        else_template
      end
    RUBY

    expression = double('expression', compile: 'expression')
    if_template = double('if_template', compile: 'if_template')
    else_template = double('else_template', compile: 'else_template')
    node = CurlyBars::Node::IfElse.new(expression, if_template, else_template)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
