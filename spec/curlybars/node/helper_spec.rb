describe Curlybars::Node::Helper do
  it "compiles with options = nil" do
    ruby_code = <<-RUBY.strip_heredoc
      options = ActiveSupport::HashWithIndifferentAccess.new

      ActiveSupport::SafeBuffer.new begin
        context = context.call
        helper = helper
        helper.call(*([context, options].compact.first(helper.arity))) do
          raise "You cannot yield a block from within a helper. Use a block helper instead."
        end
      end
    RUBY

    helper = double('helper', compile: 'helper')
    context = double('context', compile: 'context')
    options = nil
    node = Curlybars::Node::Helper.new(helper, context, options)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end

  it "compiles with options = []" do
    ruby_code = <<-RUBY.strip_heredoc
      options = ActiveSupport::HashWithIndifferentAccess.new

      ActiveSupport::SafeBuffer.new begin
        context = context.call
        helper = helper
        helper.call(*([context, options].compact.first(helper.arity))) do
          raise "You cannot yield a block from within a helper. Use a block helper instead."
        end
      end
    RUBY

    helper = double('helper', compile: 'helper')
    context = double('context', compile: 'context')
    options = []
    node = Curlybars::Node::Helper.new(helper, context, options)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end

  it "compiles with non-empty options" do
    ruby_code = <<-RUBY.strip_heredoc
      options = ActiveSupport::HashWithIndifferentAccess.new
      options.merge!(option)
      ActiveSupport::SafeBuffer.new begin
        context = context.call
        helper = helper
        helper.call(*([context, options].compact.first(helper.arity))) do
          raise "You cannot yield a block from within a helper. Use a block helper instead."
        end
      end
    RUBY

    helper = double('helper', compile: 'helper')
    context = double('context', compile: 'context')
    options = [double('options', compile: 'option')]
    node = Curlybars::Node::Helper.new(helper, context, options)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
