describe "{{> partial}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "evaluates the methods chain call" do
    template = Curlybars.compile(<<-HBS)
      {{> partial}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      partial
    HTML
  end
end
