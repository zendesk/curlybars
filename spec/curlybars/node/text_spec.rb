describe Curlybars::Node::Text do
  it "inspects text correctly" do
    text = double(:text, inspect: '"text"')

    expect(text).to receive(:inspect)

    Curlybars::Node::Text.new(text).compile
  end
end
