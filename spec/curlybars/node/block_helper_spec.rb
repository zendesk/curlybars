describe Curlybars::Node::BlockHelper do
  it "compiles the helper" do
    helper = double(:helper)
    context = double(:context, compile: 'context')
    options = nil
    template = double(:template, compile: 'template')
    helperclose = helper
    expect(helper).to receive(:compile)
    Curlybars::Node::BlockHelper.new(helper, context, options, template, helper).compile
  end

  it "compiles the context" do
    helper = double(:helper, compile: 'context')
    context = double(:context)
    options = nil
    template = double('template', compile: 'template')
    helperclose = helper
    expect(context).to receive(:compile)
    Curlybars::Node::BlockHelper.new(helper, context, options, template, helper).compile
  end

  it "compiles the template" do
    helper = double(:helper, compile: 'helper')
    context = double(:context, compile: 'context')
    options = nil
    template = double(:template)
    helperclose = helper
    expect(template).to receive(:compile)
    Curlybars::Node::BlockHelper.new(helper, context, options, template, helper).compile
  end

  it "compiles non-empty options" do
    helper = double(:helper, compile: 'helper')
    context = double(:context, compile: 'context')
    option = double(:option)
    options = [option]
    template = double(:template, compile: 'template')
    helperclose = helper
    expect(option).to receive(:compile)
    Curlybars::Node::BlockHelper.new(helper, context, options, template, helper).compile
  end

  it "accepts options = []" do
    helper = double(:helper, compile: 'helper')
    context = double(:context, compile: 'context')
    options = []
    template = double(:template, compile: 'template')
    helperclose = helper
    expect(template).to receive(:compile)
    Curlybars::Node::BlockHelper.new(helper, context, options, template, helper).compile
  end

  it "accepts options = nil" do
    helper = double(:helper, compile: 'helper')
    context = double(:context, compile: 'context')
    options = nil
    template = double(:template, compile: 'template')
    helperclose = helper
    expect(template).to receive(:compile)
    Curlybars::Node::BlockHelper.new(helper, context, options, template, helper).compile
  end

  it "raises an IncorrectEndingError when closing is not matching opening" do
    helper = 'helper'
    helperclose = 'another_helper'

    expect do
      Curlybars::Node::BlockHelper.new(helper, nil, nil, nil, helperclose)
    end.to raise_error(Curlybars::Error::IncorrectEndingError)
  end
end
