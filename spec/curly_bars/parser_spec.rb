describe CurlyBars::Parser do
  let(:context) { Object.new }
  let(:node) { double("Node") }

  it "parses a text" do
    lex = CurlyBars::Lexer.lex("a")

    allow(CurlyBars::Node::Text).
      to receive(:new).with("a") {node}

    expect(node).to receive(:compile)

    subject.parse(lex)
  end

  it "parses conditionals blocks" do
    lex = CurlyBars::Lexer.lex("{{#if a}}b{{/if}}")

    allow(CurlyBars::Node::IfBlock).
      to receive(:new).with(accessor("a").compile, [text("b").compile]).
      and_return(node)

    expect(node).to receive(:compile)

    subject.parse(lex)
  end

  skip "parses comments" do
    lex = CurlyBars::Lexer.lex("{{!foo}}")

    subject.parse(lex).should == [comment("foo")]
  end

  skip "parses component tokens" do
    lex = CurlyBars::Lexer.lex("{{a}}")

    subject.parse(lex).should == [component("a")]
  end

  skip "parses conditionals blocks with elses" do
    lex = CurlyBars::Lexer.lex("{{#if a}}b{{else}}c{{/if}}")

    subject.parse(lex).should == [conditional_block(component("a"), [text("b")], [text("c")])]
  end

  skip "parses reverse conditional blocks" do
    lex = CurlyBars::Lexer.lex("{{#unless a}}b{{/unless}}")

    subject.parse(lex).should == [inverse_conditional_block(component("a"), [text("b")])]
  end

  skip "parses reverse conditional blocks with elses" do
    lex = CurlyBars::Lexer.lex("{{#unless a}}b{{else}}c{{/unless}}")

    subject.parse(lex).should == [inverse_conditional_block(component("a"), [text("b")], [text("c")])]
  end

  skip "parses collection blocks" do
    lex = CurlyBars::Lexer.lex("{{#each a}}b{{/each}}")

    subject.parse(lex).should == [collection_block(component("a"), [text("b")])]
  end

  skip "parses collection blocks with elses" do
    lex = CurlyBars::Lexer.lex("{{#each a}}b{{else}}c{{/each}}")

    subject.parse(lex).should == [collection_block(component("a"), [text("b")], [text("c")])]
  end

  skip "parses context blocks with with syntax" do
    lex = CurlyBars::Lexer.lex("{{#with a}}b{{/with}}")

    subject.parse(lex).should == [context_block(component("a"), [text("b")])]
  end

  skip "parses context blocks with with syntax and dots" do
    lex = CurlyBars::Lexer.lex("{{#with a.b}}c{{/with}}")

    subject.parse(lex).should == [context_block(component("a", "b"), [text("c")])]
  end

  def parse(template)
    described_class.parse(CurlyBars::Lexer.lex(template))
  end

  def accessor(methods_chain)
    CurlyBars::Node::Accessor.new(methods_chain)
  end

  def component(*args)
    CurlyBars::Parser::Component.new(*args)
  end

  def text(content)
    CurlyBars::Node::Text.new(content)
  end

  def conditional_block(*args)
    CurlyBars::Parser::Block.new(:conditional, *args)
  end

  def inverse_conditional_block(*args)
    CurlyBars::Parser::Block.new(:inverse_conditional, *args)
  end

  def collection_block(*args)
    CurlyBars::Parser::Block.new(:collection, *args)
  end

  def context_block(*args)
    CurlyBars::Parser::Block.new(:context, *args)
  end

  def comment(content)
    CurlyBars::Parser::Comment.new(content)
  end
end
