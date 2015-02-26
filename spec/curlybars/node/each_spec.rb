describe Curlybars::Node::Each do
  let(:position) { double(:position, file_name: 'template.hbs', line_number: 1, line_offset: 0) }

  it "compiles path correctly" do
    path = double(:path, path: "path")
    each_template = double(:each_template, compile: 'each_template')

    expect(path).to receive(:compile)

    Curlybars::Node::Each.new(path, each_template, position).compile
  end

  it "compiles each_template correctly" do
    path = double(:path, compile: "path", path: "path")
    each_template = double(:each_template)

    expect(each_template).to receive(:compile)

    Curlybars::Node::Each.new(path, each_template, position).compile
  end
end
