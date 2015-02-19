describe Curlybars::Node::If do
  it "compiles path correctly" do
    path = double(:path)
    if_template = double(:if_template, compile: 'each_template')

    expect(path).to receive(:compile)

    Curlybars::Node::If.new(path, if_template).compile
  end

  it "compiles each_template correctly" do
    path = double(:path, compile: 'path')
    if_template = double(:if_template)

    expect(if_template).to receive(:compile)

    Curlybars::Node::If.new(path, if_template).compile
  end
end
