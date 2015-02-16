describe Curlybars::Node::Helper do
  it "raises an IncorrectEndingError when closing is not matching opening" do
    helper = 'form'
    context = 'context'
    template = ''
    helperclose = 'other'

    expect{
      Curlybars::Node::Helper.new(helper, context, template, helperclose)
    }.to raise_error(Curlybars::Error::IncorrectEndingError)
  end
end
