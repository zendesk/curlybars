describe "{{#with presenter}}...{{/with}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "works scopes one level" do
    template = compile(<<-HBS.strip_heredoc)
      {{#with user}}
        {{avatar.url}}
      {{/with}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      http://example.com/foo.png
    HTML
  end

  it "scopes two levels" do
    template = compile(<<-HBS.strip_heredoc)
      {{#with user}}
        {{#with avatar}}
          {{url}}
        {{/with}}
      {{/with}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      http://example.com/foo.png
    HTML
  end
end
