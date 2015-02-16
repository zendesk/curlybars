require 'spec_helper'
require 'curlybars/lexer'
require 'curlybars/parser'

require 'dummy/app/presenters/posts/show_presenter.rb'

describe "path expansion on presenters" do
  let(:presenter) { Posts::ShowPresenter.new }

  it "evaluates the methods chain call" do
    doc = "{{user.avatar.url}}"
    lex = Curlybars::Lexer.lex(doc)

    ruby_code = Curlybars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("http://example.com/foo.png")
  end

  it "raises when trying to call methods not implemented on context" do
      doc = "{{system}}"
      lex = Curlybars::Lexer.lex(doc)
      ruby_code = Curlybars::Parser.parse(lex).compile

      expect{eval(ruby_code)}.to raise_error(RuntimeError)
    end
end
