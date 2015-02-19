describe Curlybars::Node::UnlessElse do
  it "compiles path correctly" do
    path = double(:path)
    unless_template = double(:unless_template, compile: 'unless_template')
    else_template = double(:else_template, compile: 'else_template')

    expect(path).to receive(:compile)

    Curlybars::Node::UnlessElse.new(path, unless_template, else_template).compile
  end

  it "compiles unless_template correctly" do
    path = double(:path, compile: 'path')
    unless_template = double(:unless_template)
    else_template = double(:else_template, compile: 'else_template')

    expect(unless_template).to receive(:compile)

    Curlybars::Node::UnlessElse.new(path, unless_template, else_template).compile
  end

  it "compiles else_template correctly" do
    path = double(:path, compile: 'path')
    unless_template = double(:unless_template, compile: 'unless_template')
    else_template = double(:else_template)

    expect(else_template).to receive(:compile)

    Curlybars::Node::UnlessElse.new(path, unless_template, else_template).compile
  end
end
