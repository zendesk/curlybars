describe Curlybars::Parser do
  let(:context) { Object.new }
  let(:node) { double("Node") }

  it "parses a text" do
    lex = Curlybars::Lexer.lex("a")

    expect(Curlybars::Node::Text).
      to receive(:new).with("a")

    subject.parse(lex)
  end

  it "parses conditionals blocks" do
    lex = Curlybars::Lexer.lex("{{#if a}}b{{/if}}")

    expect(Curlybars::Node::If).
      to receive(:new).with(path("a"), template([item(text("b"))]))

    subject.parse(lex)
  end

  it "parses component tokens" do
    lex = Curlybars::Lexer.lex("{{a}}")

    expect(Curlybars::Node::Output).
      to receive(:new).with(path("a"))

    subject.parse(lex)
  end

  it "parses conditionals blocks with elses" do
    lex = Curlybars::Lexer.lex("{{#if a}}b{{else}}c{{/if}}")

    expect(Curlybars::Node::IfElse).
      to receive(:new).with(
        path("a"),
        template([item(text("b"))]),
        template([item(text("c"))])
      )

    subject.parse(lex)
  end

  it "parses reverse conditional blocks" do
    lex = Curlybars::Lexer.lex("{{#unless a}}b{{/unless}}")

    expect(Curlybars::Node::Unless).
      to receive(:new).with(
        path("a"),
        template([item(text("b"))])
      )

    subject.parse(lex)
  end

  it "parses reverse conditional blocks with elses" do
    lex = Curlybars::Lexer.lex("{{#unless a}}b{{else}}c{{/unless}}")

    expect(Curlybars::Node::UnlessElse).
      to receive(:new).with(
        path("a"),
        template([item(text("b"))]),
        template([item(text("c"))])
      )

    subject.parse(lex)
  end

  it "parses collection blocks" do
    lex = Curlybars::Lexer.lex("{{#each a}}b{{/each}}")

    expect(Curlybars::Node::Each).
      to receive(:new).with(
        path("a"),
        template([item(text("b"))])
      )

    subject.parse(lex)
  end

  it "parses collection blocks with elses" do
    lex = Curlybars::Lexer.lex("{{#each a}}b{{else}}c{{/each}}")

    expect(Curlybars::Node::EachElse).
      to receive(:new).with(
        path("a"),
        template([item(text("b"))]),
        template([item(text("c"))])
      )

    subject.parse(lex)
  end

  it "parses context blocks with with syntax" do
    lex = Curlybars::Lexer.lex("{{#with a.b.c}}b{{/with}}")

    expect(Curlybars::Node::With).
      to receive(:new).with(
        path("a.b.c"),
        template([item(text("b"))])
      )

    subject.parse(lex)
  end

  private

  def template(items)
    Curlybars::Node::Template.new(items)
  end

  def item(item)
    Curlybars::Node::Item.new(item)
  end

  def text(content)
    Curlybars::Node::Text.new(content)
  end

  def path(path)
    Curlybars::Node::Path.new(path)
  end
end
