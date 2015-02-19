describe Curlybars::Node::Item do
  it "compiles item correctly" do
    item = double(:item)

    expect(item).to receive(:compile)

    Curlybars::Node::Item.new(item).compile
  end
end
