describe Curlybars::Node::Unless do
  it "compiles correctly" do
    ruby_code =<<-RUBY.strip_heredoc
      buffer = ActiveSupport::SafeBuffer.new
      unless hbs.to_bool(expression.call)
        buffer.safe_concat(template)
      end
      buffer
    RUBY

    expression = double('expression', compile: 'expression')
    template = double('template', compile: 'template')
    node = Curlybars::Node::Unless.new(expression, template)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
