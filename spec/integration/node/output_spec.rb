describe '{{value}}' do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "prints out a string" do
    template = Curlybars.compile(<<-HBS)
      {{'hello world!'}}
    HBS

    expect(eval(template)).to resemble('hello world!')
  end

  it "prints out a boolean" do
    template = Curlybars.compile(<<-HBS)
      {{true}}
    HBS

    expect(eval(template)).to resemble('true')
  end

  it "prints out an integer" do
    template = Curlybars.compile(<<-HBS)
      {{7}}
    HBS

    expect(eval(template)).to resemble('7')
  end

  it "prints out a variable" do
    template = Curlybars.compile(<<-HBS)
      {{#each two_elements}}
        Index: {{@index}}
        First: {{@first}}
        Last: {{@last}}
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      0
      true
      false

      1
      false
      true
    HTML
  end
end
