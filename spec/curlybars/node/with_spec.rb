describe Curlybars::Node::With do
  it "compiles correctly" do
    ruby_code = <<-RUBY.strip_heredoc
      contexts << path.call
      begin
        template
      ensure
        contexts.pop
      end
    RUBY

    path = double('path', compile: 'path')
    template = double('template', compile: 'template')
    node = Curlybars::Node::With.new(path, template)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
