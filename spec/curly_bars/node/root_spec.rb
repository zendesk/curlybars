describe CurlyBars::Node::Root do
  it "compiles correctly" do
    ruby_code =<<-RUBY.strip_heredoc
      contexts = [self]
      buffer = ActiveSupport::SafeBuffer.new
      foo
      buffer
    RUBY

    template = ["foo"]
    node = CurlyBars::Node::Root.new(template)

    expect(node.compile).to eq(ruby_code)
  end
end
