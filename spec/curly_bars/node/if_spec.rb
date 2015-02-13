describe CurlyBars::Node::If do
  it "compiles correctly" do
    ruby_code =<<-RUBY.strip_heredoc
      buffer = ActiveSupport::SafeBuffer.new
      if expression
        buffer.safe_concat(template)
      end
      buffer
    RUBY

    expression = double('expression', compile: 'expression')
    template = double('template', compile: 'template')
    node = CurlyBars::Node::If.new(expression, template)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
