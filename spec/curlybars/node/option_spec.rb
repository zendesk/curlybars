describe Curlybars::Node::Option do
  it "inspects key correctly" do
    key = double(:key)
    expression = double(:expression, compile: 'expression')

    expect(key).to receive_message_chain(:to_s, :inspect)

    Curlybars::Node::Option.new(key, expression).compile
  end

  it "compiles each_template correctly" do
    key = double(:key, compile: 'path')
    expression = double(:expression)

    expect(expression).to receive(:compile)

    Curlybars::Node::Option.new(key, expression).compile
  end
end
