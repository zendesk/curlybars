describe Curlybars::Node::Unless do
  it "compiles path correctly" do
    path = double(:path)
    unless_template = double(:unless_template, compile: 'each_template')

    expect(path).to receive(:compile)

    Curlybars::Node::Unless.new(path, unless_template).compile
  end

  it "compiles each_template correctly" do
    path = double(:path, compile: 'path')
    unless_template = double(:unless_template)

    expect(unless_template).to receive(:compile)

    Curlybars::Node::Unless.new(path, unless_template).compile
  end
end
