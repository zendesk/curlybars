# frozen_string_literal: true

describe Curlybars::StreamPosition do
  describe "#start" do
    it "is the line offset" do
      position = described_class.new(10, 2, 3, 4, nil)

      expect(position.start).to eq 3
    end
  end
end
