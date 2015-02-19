describe Curlybars::Node::String do
  it "inspects string correctly" do
    string = double(:string)

    expect(string).to receive(:inspect)

    Curlybars::Node::String.new(string).compile
  end
end
