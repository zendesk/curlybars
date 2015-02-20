describe "{{#unless}}...{{/unless}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "returns unless_template when condition is false" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:condition) { true }
    presenter.stub(:condition) { false }

    template = compile(<<-HBS)
      {{#unless condition}}
        unless_template
      {{/unless}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      unless_template
    HTML
  end

  it "doesn't return unless_template when condition is true" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:condition) { true }
    presenter.stub(:condition) { true }

    template = compile(<<-HBS)
      {{#unless condition}}
        unless_template
      {{/unless}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "works with nested unless blocks (double negative)" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:first_condition) { true }
    IntegrationTest::Presenter.stub(:allows_method?).with(:second_condition) { true }
    presenter.stub(:first_condition) { false }
    presenter.stub(:second_condition) { false }

    template = compile(<<-HBS)
      {{#unless first_condition}}
        {{#unless second_condition}}
          inner_unless_template
        {{/unless}}
          outer_unless_template
      {{/unless}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      inner_unless_template
      outer_unless_template
    HTML
  end

  it "allows empty unless_template" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:valid) { true }
    presenter.stub(:valid) { true }

    template = compile(<<-HBS)
      {{#unless valid}}{{/unless}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "works with nested unless blocks (negative and positive)" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:first_condition) { true }
    IntegrationTest::Presenter.stub(:allows_method?).with(:second_condition) { true }
    presenter.stub(:first_condition) { false }
    presenter.stub(:second_condition) { true }

    template = compile(<<-HBS)
      {{#unless first_condition}}
        {{#unless second_condition}}
          inner_unless_template
        {{/unless}}
        outer_unless_template
      {{/unless}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      outer_unless_template
    HTML
  end
end
