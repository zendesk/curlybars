describe "Exception reporting" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "Throw Curlybars::Error::Lex in case of a lex error occurs" do
    expect do
      Curlybars.compile('{{{')
    end.to raise_error(Curlybars::Error::Lex)
  end

  it "Throw Curlybars::Error::Parse in case of a lex error occurs" do
    expect do
      Curlybars.compile('{{#with "notallowed"}} ... {{/with}}')
    end.to raise_error(Curlybars::Error::Parse)
  end

  it "Throw Curlybars::Error::Compile in case of a lex error occurs" do
    expect do
      Curlybars.compile('{{#form new_comment_form}} ... {{/different_closing}}')
    end.to raise_error(Curlybars::Error::Compile)
  end

  it "Throw Curlybars::Error::Render in case of a lex error occurs" do
    compiled = Curlybars.compile('{{#form not_allowed_path}} ... {{/form}}')

    expect do
      eval(compiled)
    end.to raise_error(Curlybars::Error::Render)
  end
end
