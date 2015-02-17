describe "{{#helper context key=value}}...{{/helper}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "render a block helper without options" do
    template = compile(<<-HBS)
      {{#beautify new_comment_form}}
        template
      {{/beautify}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      bold template italic
    HTML
  end

  it "render a block helper with options and presenter" do
    template = compile(<<-HBS)
      {{#form new_comment_form class="red" foo="bar"}}
        {{button_label}}
      {{/form}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      beauty class:red foo:bar submit
    HTML
  end
end
