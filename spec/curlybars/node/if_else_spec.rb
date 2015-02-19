describe Curlybars::Node::IfElse do
  it "compiles path correctly" do
    path = double(:path)
    if_template = double(:if_template, compile: 'if_template')
    else_template = double(:else_template, compile: 'else_template')

    expect(path).to receive(:compile)

    Curlybars::Node::IfElse.new(path, if_template, else_template).compile
  end

  it "compiles if_template correctly" do
    path = double(:path, compile: 'path')
    if_template = double(:if_template)
    else_template = double(:else_template, compile: 'else_template')

    expect(if_template).to receive(:compile)

    Curlybars::Node::IfElse.new(path, if_template, else_template).compile
  end

  it "compiles else_template correctly" do
    path = double(:path, compile: 'path')
    if_template = double(:if_template, compile: 'if_template')
    else_template = double(:else_template)

    expect(else_template).to receive(:compile)

    Curlybars::Node::IfElse.new(path, if_template, else_template).compile
  end
end
