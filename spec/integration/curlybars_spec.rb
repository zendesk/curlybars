require 'spec_helper'
require 'curly_bars/lexer'
require 'curly_bars/parser'

describe "integration" do
  let(:presenter) { Posts::ShowPresenter.new }

  it "runs if statement" do
    doc = "step1{{#if valid}}{{#if visible }} out{{/if}}stepX{{/if}}step2"
    lex = CurlyBars::Lexer.lex(doc)
    ruby_code = CurlyBars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("step1 outstepXstep2")
  end

  it "runs comments" do
    doc = <<-HBS.strip_heredoc
      Ciao
      {{! This is a comment }}
      {{! 2 lines
        lines }}
      {{!
        And another one
        in
        3 lines
        }
      }}
      {{!--
        And this is the {{ test }} other style
        }}
      --}}
      Goodbye
    HBS

    lex = CurlyBars::Lexer.lex(doc)
    ruby_code = CurlyBars::Parser.parse(lex).compile
    rendered = eval(ruby_code)

    expect(rendered).to eq("Ciao\n\n\n\n\nGoodbye\n")
  end

  describe "dotted notation accessors" do
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

    it "render a block helper without options" do
      doc = <<-HBS.strip_heredoc
        {{#beautify new_comment_form}}
          TEXT
        {{/beautify}}
      HBS

      lex = CurlyBars::Lexer.lex(doc)
      ruby_code = CurlyBars::Parser.parse(lex).compile
      rendered = eval(ruby_code)

      expect(rendered).to eq("bold\n  TEXT\nitalic from: new_comment_form\n")
    end

    it "render a block helper with options and presenter" do
      doc = <<-HBS.strip_heredoc
        {{#form new_comment_form class="red" foo="bar"}}
          {{ button_label }}
        {{/form}}
      HBS

      lex = CurlyBars::Lexer.lex(doc)

      ruby_code = CurlyBars::Parser.parse(lex).compile
      rendered = eval(ruby_code)

      expect(rendered).to eq("beauty new_comment_form class:red foo:bar \n  submit\n\n")
    end
  end
end
