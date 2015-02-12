describe CurlyBars::Node::IfBlock do
  it "compiles correctly" do
    ruby_code =<<-RUBY
          if true
            foo
          end
    RUBY

    expression = double('expression', compile: true)
    template = double('template', compile: 'foo')
    node = CurlyBars::Node::IfBlock.new(expression, template)

    expect(node.compile).to eq(ruby_code)
  end
end
