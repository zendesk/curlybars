require 'spec_helper'
require 'curly_bars/lexer'
require 'curly_bars/parser'

require 'dummy/app/presenters/posts/show_presenter.rb'

describe "if blocks" do
  let(:presenter) { Posts::ShowPresenter.new }

  it "returns positive branch when condition is true" do
    presenter.stub(:valid) { true }

    doc = "Start{{#if valid}}Valid{{/if}}End"

    lex = CurlyBars::Lexer.lex(doc)
    ruby_code = CurlyBars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("StartValidEnd")
  end

  it "doesn't return positive branch when condition is false" do
    presenter.stub(:valid) { false }

    doc = "Start{{#if valid}}Valid{{/if}}End"

    lex = CurlyBars::Lexer.lex(doc)
    ruby_code = CurlyBars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("StartEnd")
  end

  it "works with nested `if blocks` (double positive)" do
    presenter.stub(:valid) { true }
    presenter.stub(:visible) { true }

    doc = "Start{{#if valid}}{{#if visible}}Visible{{/if}}Valid{{/if}}End"
    lex = CurlyBars::Lexer.lex(doc)
    ruby_code = CurlyBars::Parser.parse(lex).compile

    rendered = eval(ruby_code)

    expect(rendered).to eq("StartVisibleValidEnd")
  end

  it "works with nested `if blocks` (positive and negative)" do
    presenter.stub(:valid) { true }
    presenter.stub(:visible) { false }

    doc = "Start{{#if valid}}{{#if visible}}Visible{{/if}}Valid{{/if}}End"
    lex = CurlyBars::Lexer.lex(doc)
    ruby_code = CurlyBars::Parser.parse(lex).compile

    rendered = eval(ruby_code)

    expect(rendered).to eq("StartValidEnd")
  end

  describe "runs if-else statement" do
    it "renders the if_template" do
      presenter.stub(:return_true) { true }

      doc = "{{#if return_true}}if_template{{else}}else_template{{/if}}"
      lex = CurlyBars::Lexer.lex(doc)
      ruby_code = CurlyBars::Parser.parse(lex).compile
      rendered = eval(ruby_code)

      expect(rendered).to eq("if_template")
    end

    it "renders the else_template" do
      presenter.stub(:return_false) { false }

      doc = "{{#if return_false}}if_template{{else}}else_template{{/if}}"
      lex = CurlyBars::Lexer.lex(doc)
      ruby_code = CurlyBars::Parser.parse(lex).compile
      rendered = eval(ruby_code)

      expect(rendered).to eq("else_template")
    end
  end
end
