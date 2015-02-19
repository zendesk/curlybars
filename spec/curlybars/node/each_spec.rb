describe Curlybars::Node::Each do
  it "compiles path correctly" do
    path = double(:path)
    each_template = double(:each_template, compile: 'each_template')

    expect(path).to receive(:compile)

    Curlybars::Node::Each.new(path, each_template).compile
  end

  it "compiles each_template correctly" do
    path = double(:path, compile: 'path')
    each_template = double(:each_template)

    expect(each_template).to receive(:compile)

    Curlybars::Node::Each.new(path, each_template).compile
  end
end
