describe '`\` as an escaping character' do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "escapes `{`" do
    template = Curlybars.compile(<<-HBS)
      text \\{{! text
    HBS

    expect(eval(template)).to resemble('text {{! text')
  end

  it "escapes `\\`" do
    template = Curlybars.compile(<<-HBS)
      text \\ text
    HBS

    expect(eval(template)).to resemble('text \\ text')
  end

  it "escapes `\\` at the end of the string" do
    template = Curlybars.compile('text \\')

    expect(eval(template)).to resemble('text \\')
  end
end
