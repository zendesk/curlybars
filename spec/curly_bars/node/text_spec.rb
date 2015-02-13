describe CurlyBars::Node::Text do
  it "compiles correctly" do
    ruby_code =<<-RUBY.strip_heredoc
      buffer.safe_concat("<img src=\\"foo.jpg\\"/>øåæ漢字")
    RUBY

    text = '<img src="foo.jpg"/>øåæ漢字'
    node = CurlyBars::Node::Text.new(text)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
