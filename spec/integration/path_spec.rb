require 'spec_helper'
require 'curly_bars/lexer'
require 'curly_bars/parser'

require 'dummy/app/presenters/posts/show_presenter.rb'

describe "path expansion on presenters" do
  let(:presenter) { Posts::ShowPresenter.new }

  it "evaluates the methods chain call" do
    doc = "{{ user.avatar.url }}"
    lex = CurlyBars::Lexer.lex(doc)

    ruby_code = CurlyBars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("http://example.com/foo.png")
  end

  it "raises when trying to call methods not implemented on context" do
      doc = "{{system}}"
      lex = CurlyBars::Lexer.lex(doc)
      ruby_code = CurlyBars::Parser.parse(lex).compile

      expect{eval(ruby_code)}.to raise_error(RuntimeError)
    end
end
