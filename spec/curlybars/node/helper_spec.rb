describe Curlybars::Node::Helper do
  let(:position) do
    double(:position, file_name: 'template.hbs', line_number: 1, line_offset: 0)
  end
  let(:empty_options) { {} }

  it "compiles the helper" do
    helper = double(:helper, path: 'path', position: position)
    context = double(:context, compile: 'context')
    expect(helper).to receive(:compile)
    Curlybars::Node::Helper.new(helper, context, empty_options).compile
  end

  it "compiles the context" do
    helper = double(:helper, compile: 'context', path: 'path', position: position)
    context = double(:context)
    expect(context).to receive(:compile)
    Curlybars::Node::Helper.new(helper, context, empty_options).compile
  end

  it "compiles non-empty options" do
    helper = double(:helper, compile: 'helper', path: 'path', position: position)
    context = double(:context, compile: 'context')
    option = double(:option)
    options = [option]
    expect(option).to receive(:compile)
    Curlybars::Node::Helper.new(helper, context, options).compile
  end

  it "accepts options = []" do
    helper = double(:helper, compile: 'helper', path: 'path', position: position)
    context = double(:context, compile: 'context')
    Curlybars::Node::Helper.new(helper, context, empty_options).compile
  end

  it "accepts options = nil" do
    helper = double(:helper, compile: 'helper', path: 'path', position: position)
    context = double(:context, compile: 'context')
    Curlybars::Node::Helper.new(helper, context, empty_options).compile
  end
end
