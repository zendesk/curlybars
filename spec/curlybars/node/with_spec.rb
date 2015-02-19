describe Curlybars::Node::With do
  it "compiles path correctly" do
    path = double(:path)
    template = double(:template, compile: 'template')

    expect(path).to receive(:compile)

    Curlybars::Node::With.new(path, template).compile
  end

  it "compiles template correctly" do
    path = double(:path, compile: 'path')
    template = double(:template)

    expect(template).to receive(:compile)

    Curlybars::Node::With.new(path, template).compile
  end
end
