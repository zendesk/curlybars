describe Curlybars::Node::EachElse do
  let(:position) { double(:position, file_name: 'template.hbs', line_number: 1, line_offset: 0) }

  it "delegates path, each_template and position to Curlybars::Node::Each" do
    path = double(:path, compile: "path", path: "path")
    else_template = double(:else_template, compile: 'else_template')
    each_template = double(:each_template)

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
