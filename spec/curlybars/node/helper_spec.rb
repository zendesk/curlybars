describe Curlybars::Node::Helper do
  it "compiles the helper" do
    helper = double(:helper)
    context = double(:context, compile: 'context')
    options = nil
    expect(helper).to receive(:compile)
    Curlybars::Node::Helper.new(helper, context, options).compile
  end

  it "compiles the context" do
    helper = double(:helper, compile: 'context')
    context = double(:context)
    options = nil
    expect(context).to receive(:compile)
    Curlybars::Node::Helper.new(helper, context, options).compile
  end

  it "compiles non-empty options" do
    helper = double(:helper, compile: 'helper')
    context = double(:context, compile: 'context')
    option = double(:option)
    options = [option]
    expect(option).to receive(:compile)
    Curlybars::Node::Helper.new(helper, context, options).compile
  end

  it "accepts options = []" do
    helper = double(:helper, compile: 'helper')
    context = double(:context, compile: 'context')
    options = []
    Curlybars::Node::Helper.new(helper, context, options).compile
  end

  it "accepts options = nil" do
    helper = double(:helper, compile: 'helper')
    context = double(:context, compile: 'context')
    options = nil
    Curlybars::Node::Helper.new(helper, context, options).compile
  end
end
