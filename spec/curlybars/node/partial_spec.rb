describe Curlybars::Node::Partial do
  it "compiles path correctly" do
    path = double(:path)

    expect(path).to receive(:compile)

    Curlybars::Node::Partial.new(path).compile
  end
end
