describe Curlybars::Node::EachElse do
  let(:position) { double(:position, file_name: 'template.hbs', line_number: 1, line_offset: 0) }

  it "delegates path, each_template and position to Curlybars::Node::Each" do
    path = double(:path, compile: "path", path: "path")
    each_template = double(:each_template)
    else_template = double(:else_template, compile: 'else_template')

    expect(Curlybars::Node::Each).to receive(:new)
      .with(path, each_template, position) do
        double(:compiled_each, compile: 'each_template')
      end

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
