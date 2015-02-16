require 'curlybars/lexer'
require 'curlybars/parser'

require 'dummy/app/presenters/posts/show_presenter.rb'
require 'dummy/app/helpers/curlybars_helper.rb'

describe "block helper" do
  let(:presenter) { Posts::ShowPresenter.new }

  it "render a block helper without options" do
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
end
