describe CurlyBars::Node::Each do
  it "compiles correctly" do
    ruby_code =<<-RUBY.strip_heredoc
      buffer = ActiveSupport::SafeBuffer.new
      path.each do
        buffer.safe_concat(template)
      end
      buffer
    RUBY

    path = double('path', compile: 'path')
    template = double('template', compile: 'template')
    node = CurlyBars::Node::Each.new(path, template)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
