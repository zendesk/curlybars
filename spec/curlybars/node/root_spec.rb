describe Curlybars::Node::Root do
  it "compiles the template" do
    template = double(:template)
    expect(template).to receive(:compile)

    Curlybars::Node::Root.new(template).compile
  end
end
