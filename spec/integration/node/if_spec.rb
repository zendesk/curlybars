describe "{{#if}}...{{/if}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "returns positive branch when condition is true" do
    allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:valid) { true }
    allow(presenter).to receive(:valid) { true }

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
    allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:valid) { true }
    allow(presenter).to receive(:valid) { false }

    template = compile(<<-HBS)
      {{#if valid}}
        if_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "doesn't return positive branch when condition is empty array" do
    allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:collection) { true }
    allow(presenter).to receive(:collection) { [] }

    template = compile(<<-HBS)
      {{#if collection}}
        if_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "works with nested `if blocks` (double positive)" do
    allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:valid) { true }
    allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:visible) { true }
    allow(presenter).to receive(:valid) { true }
    allow(presenter).to receive(:visible) { true }

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
    allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:valid) { true }
    allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:visible) { true }
    allow(presenter).to receive(:valid) { true }
    allow(presenter).to receive(:visible) { false }

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
    allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:valid) { true }
    allow(presenter).to receive(:valid) { true }

    template = compile(<<-HBS)
      {{#if valid}}{{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end
end
