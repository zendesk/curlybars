describe "{{#if}}...{{/if}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "returns positive branch when condition is true" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:valid) { true }
    presenter.stub(:valid) { true }

    template = compile(<<-HBS)
      {{#if valid}}
        if_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      if_template
    HTML
  end

  it "doesn't return positive branch when condition is false" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:valid) { true }
    presenter.stub(:valid) { false }

    template = compile(<<-HBS)
      {{#if valid}}
        if_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "doesn't return positive branch when condition is empty array" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:collection) { true }
    presenter.stub(:collection) { [] }

    template = compile(<<-HBS)
      {{#if collection}}
        if_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "works with nested `if blocks` (double positive)" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:valid) { true }
    IntegrationTest::Presenter.stub(:allows_method?).with(:visible) { true }
    presenter.stub(:valid) { true }
    presenter.stub(:visible) { true }

    template = compile(<<-HBS)
      {{#if valid}}
        {{#if visible}}
          inner_if_template
        {{/if}}
        outer_if_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      inner_if_template
      outer_if_template
    HTML
  end

  it "works with nested `if blocks` (positive and negative)" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:valid) { true }
    IntegrationTest::Presenter.stub(:allows_method?).with(:visible) { true }
    presenter.stub(:valid) { true }
    presenter.stub(:visible) { false }

    template = compile(<<-HBS)
      {{#if valid}}
        {{#if visible}}
          inner_if_template
        {{/if}}
        outer_if_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      outer_if_template
    HTML
  end

  it "allows empty if_template" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:valid) { true }
    presenter.stub(:valid) { true }

    template = compile(<<-HBS)
      {{#if valid}}{{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end
end
