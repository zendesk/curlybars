describe "{{#if}}...{{else}}...{{/if}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "renders the if_template" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:return_true) { true }
    presenter.stub(:return_true) { true }

    template = compile(<<-HBS)
      {{#if return_true}}
        if_template
      {{else}}
        else_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      if_template
    HTML
  end

  it "renders the else_template" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:return_false) { true }
    presenter.stub(:return_false) { false }

    template = compile(<<-HBS)
      {{#if return_false}}
        if_template
      {{else}}
        else_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      else_template
    HTML
  end
end
