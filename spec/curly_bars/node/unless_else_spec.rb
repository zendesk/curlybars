describe CurlyBars::Node::UnlessElse do
  it "compiles correctly" do
    ruby_code =<<-RUBY.strip_heredoc
      unless expression
        unless_template
      else
        else_template
      end
    RUBY

    expression = double('expression', compile: 'expression')
    unless_template = double('unless_template', compile: 'unless_template')
    else_template = double('else_template', compile: 'else_template')
    node = CurlyBars::Node::UnlessElse.new(expression, unless_template, else_template)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
