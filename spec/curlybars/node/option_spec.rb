describe Curlybars::Node::Option do
  it "compiles correctly" do
    ruby_code = <<-RUBY.strip_heredoc
      { "key" => expression.call }
    RUBY

    key = 'key'
    expression = double('expression', compile: 'expression')
    node = Curlybars::Node::Option.new(key, expression)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
