describe Curlybars::Node::EachElse do
  it "compiles path correctly" do
    path = double(:path)
    each_template = double(:each_template, compile: 'each_template')
    else_template = double(:else_template, compile: 'else_template')

    expect(path).to receive(:compile)

    Curlybars::Node::EachElse.new(path, each_template, else_template).compile
  end

  it "compiles each_template correctly" do
    path = double(:path, compile: 'path')
    each_template = double(:each_template)
    else_template = double(:else_template, compile: 'else_template')

    expect(each_template).to receive(:compile)

    Curlybars::Node::EachElse.new(path, each_template, else_template).compile
  end

  it "compiles else_template correctly" do
    path = double(:path, compile: 'path')
    each_template = double(:each_template, compile: 'each_template')
    else_template = double(:else_template)

    expect(else_template).to receive(:compile)

    Curlybars::Node::EachElse.new(path, each_template, else_template).compile
  end
end
