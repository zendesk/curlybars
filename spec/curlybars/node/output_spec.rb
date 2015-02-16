describe Curlybars::Node::Output do
  it "compiles correctly" do
    expression = double("expression", compile: 'expression')
    node = Curlybars::Node::Output.new(expression)

    ruby_code = "ActiveSupport::SafeBuffer.new(expression)\n"

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
