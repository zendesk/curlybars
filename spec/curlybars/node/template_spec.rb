describe Curlybars::Node::Template do
  it "compiles correctly with items = nil" do
    ruby_code = <<-RUBY.strip_heredoc
      Module.new do
        def self.exec(contexts, hbs)
          buffer = ActiveSupport::SafeBuffer.new

          buffer
        end
      end.exec(contexts, hbs)
    RUBY

    items = nil
    node = Curlybars::Node::Template.new(items)

    expect(node.compile.strip_heredoc.gsub(/^\s+$/, '')).to eq(ruby_code)
  end

  it "compiles correctly with items = []" do
    ruby_code = <<-RUBY.strip_heredoc
      Module.new do
        def self.exec(contexts, hbs)
          buffer = ActiveSupport::SafeBuffer.new

          buffer
        end
      end.exec(contexts, hbs)
    RUBY

    items = []
    node = Curlybars::Node::Template.new(items)

    expect(node.compile.strip_heredoc.gsub(/^\s+$/, '')).to eq(ruby_code)
  end

  it "compiles correctly with non-empty items" do
    ruby_code = <<-RUBY.strip_heredoc
      Module.new do
        def self.exec(contexts, hbs)
          buffer = ActiveSupport::SafeBuffer.new
          buffer.safe_concat(item)
          buffer
        end
      end.exec(contexts, hbs)
    RUBY

    items = [double('item', compile: 'item')]
    node = Curlybars::Node::Template.new(items)

    expect(node.compile.strip_heredoc.gsub(/^\s+$/, '')).to eq(ruby_code)
  end
end
