describe Curlybars::Node::BlockHelper do
  it "compiles the helper" do
    helper = double(:helper, path: 'helper')
    context = double(:context, compile: 'context')
    options = nil
    template = double(:template, compile: 'template')
    expect(helper).to receive(:compile)
    Curlybars::Node::BlockHelper.new(helper, context, options, template, helper).compile
  end

  it "compiles the context" do
    helper = double(:helper, compile: 'helper', path: 'helper')
    context = double(:context)
    options = nil
    template = double('template', compile: 'template')
    expect(context).to receive(:compile)
    Curlybars::Node::BlockHelper.new(helper, context, options, template, helper).compile
  end

  it "compiles the template" do
    helper = double(:helper, compile: 'helper', path: 'helper')
    context = double(:context, compile: 'context')
    options = nil
    template = double(:template)
    expect(template).to receive(:compile)
    Curlybars::Node::BlockHelper.new(helper, context, options, template, helper).compile
  end

  it "compiles non-empty options" do
    helper = double(:helper, compile: 'helper', path: 'helper')
    context = double(:context, compile: 'context')
    option = double(:option)
    options = [option]
    template = double(:template, compile: 'template')
    expect(option).to receive(:compile)
    Curlybars::Node::BlockHelper.new(helper, context, options, template, helper).compile
  end

  it "accepts options = []" do
    helper = double(:helper, compile: 'helper', path: 'helper')
    context = double(:context, compile: 'context')
    options = []
    template = double(:template, compile: 'template')
    expect(template).to receive(:compile)
    Curlybars::Node::BlockHelper.new(helper, context, options, template, helper).compile
  end

  it "accepts options = nil" do
    helper = double(:helper, compile: 'helper', path: 'helper')
    context = double(:context, compile: 'context')
    options = nil
    template = double(:template, compile: 'template')
    expect(template).to receive(:compile)
    Curlybars::Node::BlockHelper.new(helper, context, options, template, helper).compile
  end

  it "raises an IncorrectEndingError when closing is not matching opening" do
    position = double(:position, file_name: 'file_name', line_number: 1, line_offset: 0)
    helper = double(:helper, path: 'helper')
    helperclose = double(:helper, path: 'helperclose', position: position)

    expect do
      Curlybars::Node::BlockHelper.new(helper, nil, nil, nil, helperclose)
    end.to raise_error(Curlybars::Error::Compile)
  end
end
