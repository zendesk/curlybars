describe Curlybars::Node::IfElse do
  it "compiles correctly" do
    ruby_code = <<-RUBY.strip_heredoc
      collection = path.call
      if collection.any?
        buffer = ActiveSupport::SafeBuffer.new
        collection.each do |presenter|
          contexts << presenter
          begin
            buffer.safe_concat(each_template)
          ensure
            contexts.pop
          end
        end
        buffer
      else
        else_template
      end
    RUBY

    path = double('path', compile: 'path')
    each_template = double('each_template', compile: 'each_template')
    else_template = double('else_template', compile: 'else_template')
    node = Curlybars::Node::EachElse.new(path, each_template, else_template)

    expect(node.compile.strip_heredoc).to eq(ruby_code)
  end
end
