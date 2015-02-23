describe "template" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "can be empty" do
    template = compile('')

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "can contain a single curly" do
    template = compile('{')

    expect(eval(template)).to resemble(<<-HTML)
      {
    HTML
  end

  it "can contain a single backslash" do
   template = compile('\\')

   expect(eval(template)).to resemble(<<-HTML)
     \\
   HTML
  end
end
