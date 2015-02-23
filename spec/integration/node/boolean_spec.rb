describe "{{<boolean>}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "{{#if}} returns positive branch when condition is true" do
    template = compile(<<-HBS)
      {{#if true}}
        if_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      if_template
    HTML
  end

  it "{{#if}} doesn't return anything when condition is false" do
    template = compile(<<-HBS)
      {{#if false}}
        if_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "can be passes as argument to a helper" do
    template = compile(<<-HBS)
      {{echo true param=false}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      true {"param" => false}
    HTML
  end
end
