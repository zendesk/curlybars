describe Curlybars::Node::BlockHelperElse do
  let(:position) do
    double(:position, file_name: 'template.hbs', line_number: 1, line_offset: 0)
  end
  let(:context_position) do
    double(:position, file_name: 'template.hbs', line_number: 1, line_offset: 1)
  end
  let(:helper_position) do
    double(:helper_position, file_name: 'template.hbs', line_number: 1, line_offset: 1)
  end
  let(:empty_options) { {} }

  it "compiles the helper" do
    helper = double(:helper, path: 'helper', position: helper_position)
    context = double(:context, compile: "context", path: 'path', position: context_position)
    template = double(:template, compile: 'template')
    else_template = double(:else_template, compile: 'else_template')
    expect(helper).to receive(:compile)
    Curlybars::Node::BlockHelperElse.new(helper, context, empty_options, template, else_template, helper, position).compile
  end

  it "compiles the context" do
    helper = double(:helper, compile: 'helper', path: 'helper', position: helper_position)
    context = double(:context, path: 'path', position: context_position)
    template = double('template', compile: 'template')
    else_template = double(:else_template, compile: 'else_template')
    expect(context).to receive(:compile)
    Curlybars::Node::BlockHelperElse.new(helper, context, empty_options, template, else_template, helper, position).compile
  end

  it "compiles the template" do
    helper = double(:helper, compile: 'helper', path: 'helper', position: helper_position)
    context = double(:context, compile: 'context', path: 'path', position: context_position)
    template = double(:template)
    else_template = double(:else_template, compile: 'else_template')
    expect(template).to receive(:compile)
    Curlybars::Node::BlockHelperElse.new(helper, context, empty_options, template, else_template, helper, position).compile
  end

  it "compiles non-empty options" do
    helper = double(:helper, compile: 'helper', path: 'helper', position: helper_position)
    context = double(:context, compile: 'context', path: 'path', position: context_position)
    option = double(:option)
    options = [option]
    template = double(:template, compile: 'template')
    else_template = double(:else_template, compile: 'else_template')
    expect(option).to receive(:compile)
    Curlybars::Node::BlockHelperElse.new(helper, context, options, template, else_template, helper, position).compile
  end

  it "accepts options = []" do
    helper = double(:helper, compile: 'helper', path: 'helper', position: helper_position)
    context = double(:context, compile: 'context', path: 'path', position: context_position)
    template = double(:template, compile: 'template')
    else_template = double(:else_template, compile: 'else_template')
    expect(template).to receive(:compile)
    Curlybars::Node::BlockHelperElse.new(helper, context, empty_options, template, else_template, helper, position).compile
  end

  it "accepts options = nil" do
    helper = double(:helper, compile: 'helper', path: 'helper', position: helper_position)
    context = double(:context, compile: 'context', path: 'path', position: context_position)
    template = double(:template, compile: 'template')
    else_template = double(:else_template, compile: 'else_template')
    expect(template).to receive(:compile)
    Curlybars::Node::BlockHelperElse.new(helper, context, empty_options, template, else_template, helper, position).compile
  end

  it "raises an IncorrectEndingError when closing is not matching opening" do
    close_position = double(:position, file_name: 'file_name', line_number: 1, line_offset: 0)
    helper = double(:helper, path: 'helper')
    helperclose = double(:helper, path: 'helperclose', position: close_position)
    else_template = double(:else_template, compile: 'else_template')

    expect do
      Curlybars::Node::BlockHelperElse.new(helper, nil, nil, nil, else_template, helperclose, position).compile
    end.to raise_error(Curlybars::Error::Compile)
  end
end
