# frozen_string_literal: true

describe Curlybars::Token do
  describe "#==" do
    it "is equal to a token with the same type and value at another position" do
      token = described_class.new(:PATH, "a", Curlybars::StreamPosition.new(0, 0, 0, 0, nil))
      other = described_class.new(:PATH, "a", Curlybars::StreamPosition.new(5, 0, 0, 0, nil))

      expect(token).to eq other
    end

    it "is not equal to a token with another type" do
      token = described_class.new(:PATH, "a", nil)
      other = described_class.new(:KEY, "a", nil)

      expect(token).not_to eq other
    end

    it "is not equal to a token with another value" do
      token = described_class.new(:PATH, "a", nil)
      other = described_class.new(:PATH, "b", nil)

      expect(token).not_to eq other
    end
  end

  describe "#to_s" do
    it "includes the value" do
      token = described_class.new(:PATH, "a", nil)

      expect(token.to_s).to eq "PATH(a)"
    end

    it "is the type when there is no value" do
      expect(Curlybars::Token::EOS.to_s).to eq "EOS"
    end

    it "is the type when the value is false" do
      token = described_class.new(:LITERAL, false, nil)

      expect(token.to_s).to eq "LITERAL"
    end
  end
end
