require 'spec_helper'
require 'curlybars/lexer'
require 'curlybars/parser'

require 'dummy/app/presenters/posts/show_presenter.rb'

describe "comments" do
  let(:post) { double("post") }
  let(:presenter) { Posts::ShowPresenter.new(double("view_context"), post: post) }

  it "ignores one line comment" do
    doc = <<-HBS.strip_heredoc
      Start {{! This is a comment }} End
    HBS

    lex = Curlybars::Lexer.lex(doc)
    ruby_code = Curlybars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("Start  End\n")
  end

  it "ignores multi line comment" do
    doc = <<-HBS.strip_heredoc
      Start
      {{! 2 lines
        lines }}
      End
    HBS

    lex = Curlybars::Lexer.lex(doc)
    ruby_code = Curlybars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("Start\n\nEnd\n")
  end

  it "ignores multi lines with curly inside comment" do
    doc = <<-HBS.strip_heredoc
      Start
      {{!
        And another one
        in
        3 lines
        }
      }}
      End
    HBS

    lex = Curlybars::Lexer.lex(doc)
    ruby_code = Curlybars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("Start\n\nEnd\n")
  end

  it "ignores multi line comment with {{!-- --}}" do
    doc = <<-HBS.strip_heredoc
      Start
      {{!--
        And this is the {{ test }} other style
        }}
      --}}
      End
    HBS

    lex = Curlybars::Lexer.lex(doc)
    ruby_code = Curlybars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("Start\n\nEnd\n")
  end
end
