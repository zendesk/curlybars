require 'dummy/app/presenters/posts/show_presenter.rb'
require 'dummy/app/helpers/curlybars_helper.rb'

describe "block helper" do
  let(:post) { double("post") }
  let(:presenter) { Posts::ShowPresenter.new(double("view_context"), post: post) }

  it "render a block helper without options" do
    doc = <<-HBS.strip_heredoc
      {{#beautify new_comment_form}}
        TEXT
      {{/beautify}}
    HBS

    lex = Curlybars::Lexer.lex(doc)
    ruby_code = Curlybars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("bold\n  TEXT\nitalic\n")
  end

  it "render a block helper with options and presenter" do
    doc = <<-HBS.strip_heredoc
      {{#form new_comment_form class="red" foo="bar"}}
        {{ button_label }}
      {{/form}}
    HBS

    lex = Curlybars::Lexer.lex(doc)

    ruby_code = Curlybars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("beauty class:red foo:bar \n  submit\n\n")
  end
end
