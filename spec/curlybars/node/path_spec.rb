describe Curlybars::Node::Path do
  it "inspects path correctly" do
    position = double(:position, file_name: 'file_name', line_number: 1, line_offset: 0)
    path = double(:path)

    expect(path).to receive(:inspect)

    Curlybars::Node::Path.new(path, position).compile
  end
end
