describe Curlybars::Node::Template do
  it "compiles non-empty items" do
    item = double(:item)
    items = [item]
    expect(item).to receive(:compile)
    Curlybars::Node::Template.new(items).compile
  end

  it "tolerates items = []" do
    items = []
    Curlybars::Node::Template.new(items).compile
  end

  it "tolerates items = nil" do
    items = nil
    Curlybars::Node::Template.new(items).compile
  end
end
