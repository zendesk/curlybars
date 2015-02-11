describe CurlyBars::Node::Text do
  it "compiles correctly" do
    ruby_code = "buffer.safe_concat(\"lorem ipsum\")"

    value = "lorem ipsum"
    node = CurlyBars::Node::Text.new(value)

    expect(node.compile).to eq(ruby_code)
  end
end
