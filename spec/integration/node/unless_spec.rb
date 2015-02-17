describe "{{#unless}}...{{/unless}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "returns unless_template when condition is false" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:condition) { true }
    presenter.stub(:condition) { false }

    template = compile(<<-HBS.strip_heredoc)
      {{#unless condition}}
        unless_template
      {{/unless}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      unless_template
    HTML
  end

  it "doesn't return unless_template when condition is true" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:condition) { true }
    presenter.stub(:condition) { true }

    template = compile(<<-HBS.strip_heredoc)
      {{#unless condition}}
        unless_template
      {{/unless}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
    HTML
  end

  it "works with nested unless blocks (double negative)" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:first_condition) { true }
    IntegrationTest::Presenter.stub(:allows_method?).with(:second_condition) { true }
    presenter.stub(:first_condition) { false }
    presenter.stub(:second_condition) { false }

    template = compile(<<-HBS.strip_heredoc)
      {{#unless first_condition}}
        {{#unless second_condition}}
          inner_unless_template
        {{/unless}}
          outer_unless_template
      {{/unless}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      inner_unless_template
      outer_unless_template
    HTML
  end

  it "works with nested unless blocks (negative and positive)" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:first_condition) { true }
    IntegrationTest::Presenter.stub(:allows_method?).with(:second_condition) { true }
    presenter.stub(:first_condition) { false }
    presenter.stub(:second_condition) { true }

    template = compile(<<-HBS.strip_heredoc)
      {{#unless first_condition}}
        {{#unless second_condition}}
          inner_unless_template
        {{/unless}}
        outer_unless_template
      {{/unless}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      outer_unless_template
    HTML
  end
end
