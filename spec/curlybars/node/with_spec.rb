describe Curlybars::Node::With do
  let(:position) { double(:position, file_name: 'template.hbs', line_number: 1, line_offset: 0) }

  it "compiles path correctly" do
    path = double(:path, path: "path")
    template = double(:template, compile: 'template')

    expect(path).to receive(:compile)

    Curlybars::Node::With.new(path, template, position).compile
  end

  it "compiles template correctly" do
    path = double(:path, compile: "path", path: "path")
    template = double(:template)

    expect(template).to receive(:compile)

    Curlybars::Node::With.new(path, template, position).compile
  end
end
