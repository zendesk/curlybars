describe "{{#unless}}...{{else}}...{{/unless}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "renders the unless_template" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:condition) { true }
    presenter.stub(:condition) { false }

    template = compile(<<-HBS)
      {{#unless condition}}
        unless_template
      {{else}}
        else_template
      {{/unless}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      unless_template
    HTML
  end

  it "renders the else_template" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:condition) { true }
    presenter.stub(:condition) { true }

    template = compile(<<-HBS)
      {{#unless condition}}
        unless_template
      {{else}}
        else_template
      {{/unless}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      else_template
    HTML
  end
end
