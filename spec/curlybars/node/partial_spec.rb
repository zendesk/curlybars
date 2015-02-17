describe Curlybars::Node::Partial do
  it "compiles correctly" do
    ruby_code = <<-RUBY.strip_heredoc
      path.call
    RUBY

    path = double('path', compile: 'path')
    node = Curlybars::Node::Partial.new(path)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
