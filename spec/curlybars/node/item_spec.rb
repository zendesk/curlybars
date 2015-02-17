describe Curlybars::Node::Item do
  it "compiles correctly" do
    ruby_code = <<-RUBY.strip_heredoc
      Module.new do
        def self.exec(contexts)
          item
        end
      end.exec(contexts)
    RUBY

    item = double('item', compile: 'item')
    node = Curlybars::Node::Item.new(item)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
