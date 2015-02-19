describe Curlybars::Node::Path do
  it "inspects path correctly" do
    path = double(:path)

    expect(path).to receive(:inspect)

    Curlybars::Node::Path.new(path).compile
  end
end
