describe Curlybars::PartialPresenter do
  subject(:presenter) { described_class.new(nil, data) }

  let(:data) { { title: "Hello", "body" => "World" } }

  describe "#allows_method?" do
    it "returns true for keys present in data" do
      expect(presenter.allows_method?(:title)).to be true
    end

    it "returns true for string keys symbolized" do
      expect(presenter.allows_method?(:body)).to be true
    end

    it "returns false for keys not in data" do
      expect(presenter.allows_method?(:missing)).to be false
    end
  end

  describe "#method_missing" do
    it "returns the value for a known key" do
      expect(presenter.title).to eq("Hello")
    end

    it "returns the value for a string key (symbolized)" do
      expect(presenter.body).to eq("World")
    end

    it "raises NoMethodError for unknown keys" do
      expect { presenter.missing }.to raise_error(NoMethodError)
    end
  end

  describe "#respond_to_missing?" do
    it "returns true for known keys" do
      expect(presenter.respond_to?(:title)).to be true
    end

    it "returns false for unknown keys" do
      expect(presenter.respond_to?(:missing)).to be false
    end
  end

  describe "with empty data" do
    let(:data) { {} }

    it "allows no methods" do
      expect(presenter.allows_method?(:anything)).to be false
    end
  end
end
