describe CurlyBars::Node::IfElse do
  it "compiles correctly" do
    ruby_code =<<-RUBY.strip_heredoc
      collection = path
      if collection.any?
        buffer = ActiveSupport::SafeBuffer.new
        collection.each do
          buffer.safe_concat(each_template)
        end
        buffer
      else
        else_template
      end
    RUBY

    path = double('path', compile: 'path')
    each_template = double('each_template', compile: 'each_template')
    else_template = double('else_template', compile: 'else_template')
    node = CurlyBars::Node::EachElse.new(path, each_template, else_template)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
