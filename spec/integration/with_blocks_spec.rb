require 'spec_helper'
require 'curly_bars/lexer'
require 'curly_bars/parser'

require 'dummy/app/presenters/posts/show_presenter.rb'

describe "with blocks" do
  let(:presenter) { Posts::ShowPresenter.new }

  it "works with {{#with block version b" do
    doc = "{{#with user}}Hello {{avatar.url}}{{/with}}"

    lex = CurlyBars::Lexer.lex(doc)
    ruby_code = CurlyBars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("Hello http://example.com/foo.png")
  end

  it "works with 2 nested {{#with blocks" do
    doc = "{{#with user}}Hello {{#with avatar}}{{url}}{{/with}}{{/with}}"
    lex = CurlyBars::Lexer.lex(doc)
    ruby_code = CurlyBars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("Hello http://example.com/foo.png")
  end
end
