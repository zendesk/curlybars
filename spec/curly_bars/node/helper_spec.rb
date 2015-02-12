describe CurlyBars::Node::Helper do
  it "raises an IncorrectEndingError when closing is not matching opening" do
    helper = 'form'
    context = 'context'
    template = ''
    helperclose = 'other'

    expect{
      CurlyBars::Node::Helper.new(helper, context, template, helperclose)
    }.to raise_error(CurlyBars::Error::IncorrectEndingError)
  end
end
