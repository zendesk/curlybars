require 'dummy/app/presenters/posts/show_presenter.rb'

describe "with blocks" do
  let(:post) { double("post") }
  let(:presenter) { Posts::ShowPresenter.new(double("view_context"), post: post) }

  it "works with {{#with block version b" do
    doc = "{{#with user}}Hello {{avatar.url}}{{/with}}"

    lex = Curlybars::Lexer.lex(doc)
    ruby_code = Curlybars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("Hello http://example.com/foo.png")
  end

  it "works with 2 nested {{#with blocks" do
    doc = "{{#with user}}Hello {{#with avatar}}{{url}}{{/with}}{{/with}}"
    lex = Curlybars::Lexer.lex(doc)
    ruby_code = Curlybars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("Hello http://example.com/foo.png")
  end
end
