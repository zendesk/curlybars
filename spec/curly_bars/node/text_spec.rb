describe CurlyBars::Node::Text do
  it "compiles correctly" do
    ruby_code = "buffer << \"lorem ipsum\"\n"

    text = "lorem ipsum"
    node = CurlyBars::Node::Text.new(text)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
