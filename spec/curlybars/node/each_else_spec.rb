describe Curlybars::Node::EachElse do
  let(:position) { double(:position, file_name: 'template.hbs', line_number: 1, line_offset: 0) }

  it "compiles path correctly" do
    path = double(:path, path: "path")
    each_template = double(:each_template, compile: 'each_template')
    else_template = double(:else_template, compile: 'else_template')

    expect(path).to receive(:compile)

    Curlybars::Node::EachElse.new(path, each_template, else_template, position).compile
  end

  it "compiles each_template correctly" do
    path = double(:path, compile: "path", path: "path")
    each_template = double(:each_template)
    else_template = double(:else_template, compile: 'else_template')

    expect(each_template).to receive(:compile)

    Curlybars::Node::EachElse.new(path, each_template, else_template, position).compile
  end

  it "compiles else_template correctly" do
    path = double(:path, compile: "path", path: "path")
    each_template = double(:each_template, compile: 'each_template')
    else_template = double(:else_template)

    expect(else_template).to receive(:compile)

    Curlybars::Node::EachElse.new(path, each_template, else_template, position).compile
  end
end
