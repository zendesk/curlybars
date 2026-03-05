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

  describe "singleton methods" do
    it "returns the value for a known key" do
      expect(presenter.title).to eq("Hello")
    end

    it "returns the value for a string key (symbolized)" do
      expect(presenter.body).to eq("World")
    end

    it "raises NoMethodError for unknown keys" do
      expect { presenter.missing }.to raise_error(NoMethodError)
    end

    it "returns a Method object via #method" do
      expect(presenter.method(:title)).to be_a(Method)
    end

    it "returns the correct value when calling the Method object" do
      expect(presenter.method(:title).call).to eq("Hello")
    end
  end

  describe "#respond_to?" do
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

  describe "subclass with allow_methods" do
    let(:subclass) do
      Class.new(described_class) do
        extend Curlybars::MethodWhitelist

        allow_methods :site_name

        def site_name
          "TestSite"
        end
      end
    end

    it "recognizes declared methods via allows_method?" do
      instance = subclass.new(nil, { title: "Hi" })
      expect(instance.allows_method?(:site_name)).to be true
    end

    it "recognizes dynamic data keys via allows_method?" do
      instance = subclass.new(nil, { title: "Hi" })
      expect(instance.allows_method?(:title)).to be true
    end

    it "returns dynamic data values" do
      instance = subclass.new(nil, { title: "Hi" })
      expect(instance.title).to eq("Hi")
    end

    it "returns declared method values" do
      instance = subclass.new(nil, {})
      expect(instance.site_name).to eq("TestSite")
    end
  end
end
