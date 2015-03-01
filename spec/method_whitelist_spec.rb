describe Curlybars::MethodWhitelist do
  let(:dummy_class) { Class.new { extend Curlybars::MethodWhitelist } }

  describe "#allowed_methods" do
    it "should return an empty array as default" do
      expect(dummy_class.new.allowed_methods).to eq([])
    end
  end

  describe ".allow_methods" do
    before do
      dummy_class.class_eval do
        allow_methods :cook
      end
    end

    it "should set the allowed methods" do
      expect(dummy_class.new.allowed_methods).to eq([:cook])
    end
  end

  describe "inheritance and composition" do
    let (:base_presenter) do
      Class.new do
        extend Curlybars::MethodWhitelist
        allow_methods :cook
      end
    end

    let (:helpers) do
      Module.new do
        extend Curlybars::MethodWhitelist
        allow_methods :form
      end
    end

    let (:post_presenter) do
      Class.new(base_presenter) do
        extend Curlybars::MethodWhitelist
        allow_methods :wave
      end
    end

    before do
      post_presenter.include helpers
    end

    it "should allow methods from inheritance and composition" do
      expect(post_presenter.new.allowed_methods).to eq([:cook, :form, :wave])
    end
  end
end
