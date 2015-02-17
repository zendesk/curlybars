require 'dummy/app/presenters/posts/show_presenter.rb'
require 'dummy/app/helpers/curlybars_helper.rb'

describe "block helper" do
  let(:post) { double("post") }
  let(:presenter) { Posts::ShowPresenter.new(double("view_context"), post: post) }

  it "renders a helper with expression and options" do
    doc = "{{date user.created_at class='metadata'}}"

    lex = Curlybars::Lexer.lex(doc)
    ruby_code = Curlybars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq(
      <<-HTML.strip_heredoc
        <time datetime="2015-02-03T13:25:06Z" class="metadata">
          February 3, 2015 13:25
        </time>
      HTML
    )
  end

  it "renders a helper with only expression" do
    doc = <<-HTML.strip_heredoc
      <script src="{{asset "jquery_plugin.js"}}"></script>
    HTML

    lex = Curlybars::Lexer.lex(doc)
    ruby_code = Curlybars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq(
      <<-HTML.strip_heredoc
        <script src="http://cdn.example.com/jquery_plugin.js"></script>
      HTML
    )
  end

  it "renders a helper with only options" do
    doc = <<-HTML.strip_heredoc.strip
      {{#with new_comment_form}}
        {{input title class="form-control"}}
      {{/with}}
    HTML

    lex = Curlybars::Lexer.lex(doc)
    ruby_code = Curlybars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq(
      %Q{\n  <input name="community_post[title]" id="community_post_title" type="text" class="form-control" value="some value persisted in the DB">\n\n}
    )
  end
end
