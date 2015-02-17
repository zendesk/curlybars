describe Curlybars::Node::String do
  it "compiles correctly" do
    ruby_code = <<-RUBY.strip_heredoc
      ->() { ActiveSupport::SafeBuffer.new("string") }
    RUBY

    node = Curlybars::Node::String.new('string')

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
