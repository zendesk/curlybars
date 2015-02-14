describe CurlyBars::Parser do
  let(:context) { Object.new }
  let(:node) { double("Node") }

  it "parses a text" do
    lex = CurlyBars::Lexer.lex("a")

    expect(CurlyBars::Node::Text).
      to receive(:new).with("a")

    subject.parse(lex)
  end

  it "parses conditionals blocks" do
    lex = CurlyBars::Lexer.lex("{{#if a}}b{{/if}}")

    expect(CurlyBars::Node::IfBlock).
      to receive(:new).with(path("a"), template([text("b")]))

    subject.parse(lex)
  end

  it "parses component tokens" do
    lex = CurlyBars::Lexer.lex("{{a}}")

    expect(CurlyBars::Node::Output).
      to receive(:new).with(path("a"))

    subject.parse(lex)
  end

  it "parses conditionals blocks with elses" do
    lex = CurlyBars::Lexer.lex("{{#if a}}b{{else}}c{{/if}}")

    expect(CurlyBars::Parser::Block).
      to receive(:new).with(
        :conditional,
        path("a"),
        template([text("b")]),
        template([text("c")])
      )

    subject.parse(lex)
  end

  it "parses reverse conditional blocks" do
    lex = CurlyBars::Lexer.lex("{{#unless a}}b{{/unless}}")

    expect(CurlyBars::Parser::Block).
      to receive(:new).with(
        :inverse_conditional,
        path("a"),
        template([text("b")])
      )

    subject.parse(lex)
  end

  it "parses reverse conditional blocks with elses" do
    lex = CurlyBars::Lexer.lex("{{#unless a}}b{{else}}c{{/unless}}")

    expect(CurlyBars::Parser::Block).
      to receive(:new).with(
        :inverse_conditional,
        path("a"),
        template([text("b")]),
        template([text("c")])
      )

    subject.parse(lex)
  end

  it "parses collection blocks" do
    lex = CurlyBars::Lexer.lex("{{#each a}}b{{/each}}")

    expect(CurlyBars::Parser::Block).
      to receive(:new).with(
        :collection,
        path("a"),
        template([text("b")])
      )

    subject.parse(lex)
  end

  it "parses collection blocks with elses" do
    lex = CurlyBars::Lexer.lex("{{#each a}}b{{else}}c{{/each}}")

    expect(CurlyBars::Parser::Block).
      to receive(:new).with(
        :collection,
        path("a"),
        template([text("b")]),
        template([text("c")])
      )

    subject.parse(lex)
  end

  it "parses context blocks with with syntax" do
    lex = CurlyBars::Lexer.lex("{{#with a.b.c}}b{{/with}}")

    expect(CurlyBars::Node::With).
      to receive(:new).with(
        path("a.b.c"),
        template([text("b")])
      )

    subject.parse(lex)
  end

  private

  def template(items)
    CurlyBars::Node::Template.new(items)
  end

  def path(methods_chain)
    CurlyBars::Node::Path.new(methods_chain)
  end

  def text(content)
    CurlyBars::Node::Text.new(content)
  end
end
