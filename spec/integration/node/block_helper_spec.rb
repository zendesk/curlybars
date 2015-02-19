describe "{{#helper context key=value}}...{{/helper}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "renders a block helper without options" do
    template = compile(<<-HBS)
      {{#beautify new_comment_form}}
        template
      {{/beautify}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      bold template italic
    HTML
  end

  it "renders a block helper with options and presenter" do
    template = compile(<<-HBS)
      {{#form new_comment_form class="red" foo="bar"}}
        {{button_label}}
      {{/form}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      beauty class:red foo:bar submit
    HTML
  end

  it "allow empty template" do
    template = compile(<<-HBS)
      {{#form new_comment_form class="red" foo="bar"}}{{/form}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      beauty class:red foo:bar
    HTML
  end

  it "renders correctly a return type of integer" do
    template = compile(<<-HBS)
      {{#integer new_comment_form}} text {{/integer}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      0
    HTML
  end

  it "renders correctly a return type of boolean" do
    template = compile(<<-HBS)
      {{#boolean new_comment_form}} text {{/boolean}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      true
    HTML
  end
end
