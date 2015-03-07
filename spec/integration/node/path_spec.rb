describe "{{path}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "evaluates the methods chain call" do
    template = Curlybars.compile(<<-HBS)
      {{user.avatar.url}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      http://example.com/foo.png
    HTML
  end

  it "{{../path}} is evaluated on the second to last context in the stack" do
    template = Curlybars.compile(<<-HBS)
      {{#with user.avatar}}
        {{../method_in_root_presenter}}
      {{/with}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      method_in_root_presenter
    HTML
  end

  it "{{../../path}} is evaluated on the third to last context in the stack" do
    template = Curlybars.compile(<<-HBS)
      {{#with user}}
        {{#with avatar}}
          {{../../method_in_root_presenter}}
        {{/with}}
      {{/with}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      method_in_root_presenter
    HTML
  end

  it "a path with more `../` than the stack size will resolve to the root presenter" do
    template = Curlybars.compile(<<-HBS)
      {{method_in_root_presenter}}
      {{../method_in_root_presenter}}
      {{../../method_in_root_presenter}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      method_in_root_presenter
      method_in_root_presenter
      method_in_root_presenter
    HTML
  end

  it "raises when trying to call methods not implemented on context" do
    template = Curlybars.compile(<<-HBS)
      {{not_in_whitelist}}
    HBS

    expect do
      eval(eval(template))
    end.to raise_error(Curlybars::Error::Render)
  end
end
