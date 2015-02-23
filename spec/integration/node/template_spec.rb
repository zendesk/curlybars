describe "template" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "raises an exception when contexts stack is too deep (>= 10)" do
    template = compile(hbs_with_depth(10))

    expect do
      eval(template)
    end.to raise_error(RuntimeError)
  end

  it "raises an exception when contexts stack is not too deep (< 10)" do
    template = compile(hbs_with_depth(9))

    expect do
      eval(template)
    end.not_to raise_error
  end

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

  private

  def hbs_with_depth(depth)
    hbs = "%s"
    depth.times { hbs = hbs % "{{#with me}}%s{{/with}}" }
    hbs = hbs % ''
  end
end
