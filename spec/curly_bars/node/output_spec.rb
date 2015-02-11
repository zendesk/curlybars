describe CurlyBars::Node::Output do
  it "compiles correctly" do
    node = CurlyBars::Node::Output.new("foo")

    ruby_code = "buffer << foo"

    expect(node.compile).to eq(ruby_code)
  end
end
