describe Curlybars::Node::BlockHelper do
  it "raises an IncorrectEndingError when closing is not matching opening" do
    helper = 'form'
    context = 'context'
    template = ''
    helperclose = 'other'

    expect{
      Curlybars::Node::BlockHelper.new(helper, context, template, helperclose)
    }.to raise_error(Curlybars::Error::IncorrectEndingError)
  end
end
