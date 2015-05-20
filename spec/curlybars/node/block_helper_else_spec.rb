describe Curlybars::Node::BlockHelperElse do
  let(:position) do
    double(:position, file_name: 'template.hbs', line_number: 1, line_offset: 0)
  end
  let(:argument_position) do
    double(:position, file_name: 'template.hbs', line_number: 1, line_offset: 1)
  end
  let(:helper_position) do
    double(:helper_position, file_name: 'template.hbs', line_number: 1, line_offset: 1)
  end
  let(:empty_arguments) { [] }
  let(:empty_options) { {} }

  it "compiles the helper" do
    helper = double(:helper, path: 'helper', position: helper_position)
    argument = double(:argument, compile: "argument", path: 'path', position: argument_position)
    arguments = [argument]
    helper_template = double(:helper_template, compile: 'helper_template')
    else_template = double(:else_template, compile: 'else_template')
    expect(helper).to receive(:compile)
    Curlybars::Node::BlockHelperElse.new(helper, arguments, empty_options, helper_template, else_template, helper, position).compile
  end

  it "compiles the argument" do
    helper = double(:helper, compile: 'helper', path: 'helper', position: helper_position)
    argument = double(:argument, path: 'path', position: argument_position)
    arguments = [argument]
    helper_template = double('helper_template', compile: 'helper_template')
    else_template = double(:else_template, compile: 'else_template')
    expect(argument).to receive(:compile)
    Curlybars::Node::BlockHelperElse.new(helper, arguments, empty_options, helper_template, else_template, helper, position).compile
  end

  it "compiles the helper_template" do
    helper = double(:helper, compile: 'helper', path: 'helper', position: helper_position)
    argument = double(:argument, compile: 'argument', path: 'path', position: argument_position)
    arguments = [argument]
    helper_template = double(:helper_template)
    else_template = double(:else_template, compile: 'else_template')
    expect(helper_template).to receive(:compile)
    Curlybars::Node::BlockHelperElse.new(helper, arguments, empty_options, helper_template, else_template, helper, position).compile
  end

  it "compiles the else_template" do
    helper = double(:helper, compile: 'helper', path: 'helper', position: helper_position)
    argument = double(:argument, compile: 'argument', path: 'path', position: argument_position)
    arguments = [argument]
    helper_template = double(:helper_template, compile: 'helper_template')
    else_template = double(:else_template)
    expect(else_template).to receive(:compile)
    Curlybars::Node::BlockHelperElse.new(helper, arguments, empty_options, helper_template, else_template, helper, position).compile
  end

  it "compiles non-empty options" do
    helper = double(:helper, compile: 'helper', path: 'helper', position: helper_position)
    argument = double(:argument, compile: 'argument', path: 'path', position: argument_position)
    arguments = [argument]
    option = double(:option)
    options = [option]
    helper_template = double(:helper_template, compile: 'helper_template')
    else_template = double(:else_template, compile: 'else_template')
    expect(option).to receive(:compile)
    Curlybars::Node::BlockHelperElse.new(helper, arguments, options, helper_template, else_template, helper, position).compile
  end

  it "accepts arguments = []" do
    helper = double(:helper, compile: 'helper', path: 'helper', position: helper_position)
    helper_template = double(:helper_template, compile: 'helper_template')
    option = double(:option, compile: 'option')
    options = [option]
    else_template = double(:else_template, compile: 'else_template')
    expect(helper_template).to receive(:compile)
    Curlybars::Node::BlockHelperElse.new(helper, empty_arguments, options, helper_template, else_template, helper, position).compile
  end

  it "accepts options = []" do
    helper = double(:helper, compile: 'helper', path: 'helper', position: helper_position)
    argument = double(:argument, compile: 'argument', path: 'path', position: argument_position)
    arguments = [argument]
    helper_template = double(:helper_template, compile: 'helper_template')
    else_template = double(:else_template, compile: 'else_template')
    expect(helper_template).to receive(:compile)
    Curlybars::Node::BlockHelperElse.new(helper, arguments, empty_options, helper_template, else_template, helper, position).compile
  end

  it "raises an IncorrectEndingError when closing is not matching opening" do
    close_position = double(:position, file_name: 'file_name', line_number: 1, line_offset: 0)
    helper_template = double(:helper_template, path: 'helper_template')
    helperclose = double(:helper, path: 'helperclose', position: close_position)
    else_template = double(:else_template, compile: 'else_template')

    expect do
      Curlybars::Node::BlockHelperElse.new(helper_template, nil, nil, nil, else_template, helperclose, position).compile
    end.to raise_error(Curlybars::Error::Compile)
  end
end
