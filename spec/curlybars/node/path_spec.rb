describe Curlybars::Node::Path do
  it "compiles correctly" do
    node = Curlybars::Node::Path.new("path")

    ruby_code = <<-RUBY.strip_heredoc
      hbs.path("path")
    RUBY

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
