describe Curlybars::Node::BlockHelper do
  it "compiles with options = nil" do
    ruby_code = <<-RUBY.strip_heredoc
      options = ActiveSupport::HashWithIndifferentAccess.new

      ActiveSupport::SafeBuffer.new begin
          context = context.call
          helper = helper
          helper.call(*([context, options].first(helper.arity))) do
            contexts << context
            begin
              template
            ensure
              contexts.pop
            end
          end
        end
    RUBY

    helper = double('helper', compile: 'helper')
    context = double('context', compile: 'context')
    options = nil
    template = double('template', compile: 'template')
    helperclose = helper
    node = Curlybars::Node::BlockHelper.new(helper, context, options, template, helperclose)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end

  it "compiles with options = []" do
    ruby_code = <<-RUBY.strip_heredoc
      options = ActiveSupport::HashWithIndifferentAccess.new

      ActiveSupport::SafeBuffer.new begin
          context = context.call
          helper = helper
          helper.call(*([context, options].first(helper.arity))) do
            contexts << context
            begin
              template
            ensure
              contexts.pop
            end
          end
        end
    RUBY

    helper = double('helper', compile: 'helper')
    context = double('context', compile: 'context')
    options = []
    template = double('template', compile: 'template')
    helperclose = helper
    node = Curlybars::Node::BlockHelper.new(helper, context, options, template, helperclose)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end

  it "compiles with non-empty options" do
    ruby_code = <<-RUBY.strip_heredoc
      options = ActiveSupport::HashWithIndifferentAccess.new
      options.merge!(option)
      ActiveSupport::SafeBuffer.new begin
          context = context.call
          helper = helper
          helper.call(*([context, options].first(helper.arity))) do
            contexts << context
            begin
              template
            ensure
              contexts.pop
            end
          end
        end
    RUBY

    helper = double('helper', compile: 'helper')
    context = double('context', compile: 'context')
    options = [double('options', compile: 'option')]
    template = double('template', compile: 'template')
    helperclose = helper
    node = Curlybars::Node::BlockHelper.new(helper, context, options, template, helperclose)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end

  it "raises an IncorrectEndingError when closing is not matching opening" do
    helper = 'helper'
    helperclose = 'another_helper'

    expect{
      Curlybars::Node::BlockHelper.new(helper, nil, nil, nil, helperclose)
    }.to raise_error(Curlybars::Error::IncorrectEndingError)
  end
end
