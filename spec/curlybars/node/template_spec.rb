describe Curlybars::Node::Template do
  let(:position) { double(:position, file_name: 'template.hbs', line_number: 1, line_offset: 0) }

  it "compiles non-empty items" do
    item = double(:item)
    items = [item]
    expect(item).to receive(:compile)
    Curlybars::Node::Template.new(items, position).compile
  end

  it "tolerates items = []" do
    items = []
    Curlybars::Node::Template.new(items, position).compile
  end

  it "tolerates items = nil" do
    items = nil
    Curlybars::Node::Template.new(items, position).compile
  end
end
