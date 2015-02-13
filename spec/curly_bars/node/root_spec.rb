describe CurlyBars::Node::Root do
  it "compiles correctly" do
    ruby_code =<<-RUBY.strip_heredoc
      contexts = [presenter]
      ActiveSupport::SafeBuffer.new.safe_concat(foo)
    RUBY

    template = double("template", compile: "foo")
    node = CurlyBars::Node::Root.new(template)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
