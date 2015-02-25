describe '`\` as an escaping character' do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "escapes `{`" do
    template = Curlybars.compile(<<-HBS)
      \\{{!
    HBS

    expect(eval(template)).to resemble('{{!')
  end
end
