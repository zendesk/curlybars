describe "{{'literal'}}" do
  describe "#cache_key" do
    it "includes the literal and the class name" do
      literal = Curlybars::Node::Literal.new("42")

      expect(literal.cache_key).to eq("42/Curlybars::Node::Literal")
    end

    it "differs between literals" do
      one = Curlybars::Node::Literal.new("1")
      two = Curlybars::Node::Literal.new("2")

      expect(one.cache_key).not_to eq(two.cache_key)
    end
  end
end
