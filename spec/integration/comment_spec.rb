describe "{{!-- --}} and {{! }}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }
  let(:global_helpers_providers) { [] }

  it "ignores one line comment" do
    template = Curlybars.compile(<<-HBS)
      before{{! This is a comment }}after
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      before after
    HTML
  end

  it "ignores multi line comment" do
    template = Curlybars.compile(<<-HBS)
      before
      {{! 2 lines
        lines }}
      after
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      before after
    HTML
  end

  it "ignores multi lines with curly inside comment" do
    template = Curlybars.compile(<<-HBS)
      before
      {{!
        And another one
        in
        3 lines
        }
      }}
      after
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      before after
    HTML
  end

  it "ignores multi line comment with {{!-- --}}" do
    template = Curlybars.compile(<<-HBS)
      before
      {{!--
        And this is the {{ test }} other style
        }}
      --}}
      after
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      before after
    HTML
  end
end
