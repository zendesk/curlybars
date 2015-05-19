describe Curlybars::Node::WithElse do
  let(:position) { double(:position, file_name: 'template.hbs', line_number: 1, line_offset: 0) }

  it "compiles path correctly" do
    path = double(:path, path: "path")
    with_template = double(:with_template, compile: 'with_template')
    else_template = double(:else_template, compile: 'else_template')

    expect(path).to receive(:compile)

    Curlybars::Node::WithElse.new(path, with_template, else_template, position).compile
  end

  it "compiles with_template correctly" do
    path = double(:path, compile: "path", path: "path")
    else_template = double(:else_template, compile: 'else_template')
    with_template = double(:with_template)

    expect(with_template).to receive(:compile)

    Curlybars::Node::WithElse.new(path, with_template, else_template, position).compile
  end

  it "compiles else_template correctly" do
    path = double(:path, compile: "path", path: "path")
    with_template = double(:with_template, compile: 'with_template')
    else_template = double(:else_template)

    expect(else_template).to receive(:compile)

    Curlybars::Node::WithElse.new(path, with_template, else_template, position).compile
  end
end
