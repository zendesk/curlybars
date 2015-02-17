describe "with blocks" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "works with {{#with block version b" do
    template = compile(<<-HBS.strip_heredoc)
      {{#with user}}
        {{avatar.url}}
      {{/with}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      http://example.com/foo.png
    HTML
  end

  it "works with 2 nested {{#with blocks" do
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
