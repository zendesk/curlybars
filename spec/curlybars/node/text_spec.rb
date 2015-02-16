describe Curlybars::Node::Text do
  it "compiles correctly" do
    ruby_code = "\"<img src=\\\\\\\"foo.jpg\\\\\\\"/>øåæ漢字\""

    text = '<img src=\"foo.jpg\"/>øåæ漢字'
    node = Curlybars::Node::Text.new(text)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
