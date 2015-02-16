describe Curlybars::Node::Root do
  it "compiles correctly" do
    ruby_code =<<-RUBY.strip_heredoc
      contexts = [presenter]
      ActiveSupport::SafeBuffer.new(template)
    RUBY

    template = double("template", compile: "template")
    node = Curlybars::Node::Root.new(template)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
