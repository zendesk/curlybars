describe "{{<integer>}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "{{#if}} returns positive branch when condition is 1" do
    template = compile(<<-HBS)
      {{#if 1}}
        if_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      if_template
    HTML
  end

  it "{{#if}} doesn't return anything when condition is 0" do
    template = compile(<<-HBS)
      {{#if 0}}
        if_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "can be passes as argument to a helper" do
    template = compile(<<-HBS)
      {{echo 0 param=1}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      0 {"param" => 1}
    HTML
  end
end
