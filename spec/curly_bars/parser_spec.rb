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

    expect(CurlyBars::Node::If).
      to receive(:new).with(path("a"), template([item(text("b"))]))

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

    expect(CurlyBars::Node::IfElse).
      to receive(:new).with(
        path("a"),
        template([item(text("b"))]),
        template([item(text("c"))])
      )

    subject.parse(lex)
  end

  it "parses reverse conditional blocks" do
    lex = CurlyBars::Lexer.lex("{{#unless a}}b{{/unless}}")

    expect(CurlyBars::Node::Unless).
      to receive(:new).with(
        path("a"),
        template([item(text("b"))])
      )

    subject.parse(lex)
  end

  it "parses reverse conditional blocks with elses" do
    lex = CurlyBars::Lexer.lex("{{#unless a}}b{{else}}c{{/unless}}")

    expect(CurlyBars::Node::UnlessElse).
      to receive(:new).with(
        path("a"),
        template([item(text("b"))]),
        template([item(text("c"))])
      )

    subject.parse(lex)
  end

  it "parses collection blocks" do
    lex = CurlyBars::Lexer.lex("{{#each a}}b{{/each}}")

    expect(CurlyBars::Node::Each).
      to receive(:new).with(
        path("a"),
        template([item(text("b"))])
      )

    subject.parse(lex)
  end

  it "parses collection blocks with elses" do
    lex = CurlyBars::Lexer.lex("{{#each a}}b{{else}}c{{/each}}")

    expect(CurlyBars::Node::EachElse).
      to receive(:new).with(
        path("a"),
        template([item(text("b"))]),
        template([item(text("c"))])
      )

    subject.parse(lex)
  end

  it "parses context blocks with with syntax" do
    lex = CurlyBars::Lexer.lex("{{#with a.b.c}}b{{/with}}")

    expect(CurlyBars::Node::With).
      to receive(:new).with(
        path("a.b.c"),
        template([item(text("b"))])
      )

    subject.parse(lex)
  end

  private

  def template(items)
    CurlyBars::Node::Template.new(items)
  end

  def item(item)
    CurlyBars::Node::Item.new(item)
  end

  def text(content)
    CurlyBars::Node::Text.new(content)
  end

  def path(path)
    CurlyBars::Node::Path.new(path)
  end
end
