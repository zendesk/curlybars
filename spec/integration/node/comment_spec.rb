describe "comments" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "ignores one line comment" do
    template = compile(<<-HBS.strip_heredoc)
      before{{! This is a comment }}after
    HBS

    expect(eval(template)).to resemble("beforeafter\n")
  end

  it "ignores multi line comment" do
    template = compile(<<-HBS.strip_heredoc)
      before
      {{! 2 lines
        lines }}
      after
    HBS

    expect(eval(template)).to resemble("before\n\nafter\n")
  end

  it "ignores multi lines with curly inside comment" do
    template = compile(<<-HBS.strip_heredoc)
      before
      {{!
        And another one
        in
        3 lines
        }
      }}
      after
    HBS

    expect(eval(template)).to resemble("before\n\nafter\n")
  end

  it "ignores multi line comment with {{!-- --}}" do
    template = compile(<<-HBS.strip_heredoc)
      before
      {{!--
        And this is the {{ test }} other style
        }}
      --}}
      after
    HBS

    expect(eval(template)).to resemble("before\n\nafter\n")
  end
end
