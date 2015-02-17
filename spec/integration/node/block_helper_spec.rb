describe "block helper" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "render a block helper without options" do
    template = compile(<<-HBS.strip_heredoc)
      {{#beautify new_comment_form}}
        template
      {{/beautify}}
    HBS

    expect(eval(template)).to resemble("bold\n  template\nitalic\n")
  end

  it "render a block helper with options and presenter" do
    template = compile(<<-HBS.strip_heredoc)
      {{#form new_comment_form class="red" foo="bar"}}
        {{button_label}}
      {{/form}}
    HBS

    expect(eval(template)).to resemble("beauty class:red foo:bar \n  submit\n\n")
  end
end
