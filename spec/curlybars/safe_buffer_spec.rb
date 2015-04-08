describe Curlybars::SafeBuffer do
  let(:configuration) { double(:configuration) }

  before do
    allow(Curlybars).to receive(:configuration) { configuration }
  end

  describe "#safe_concat" do
    it "accepts when (buffer length + the existing output lenght) <= output_limit" do
      allow(configuration).to receive(:output_limit) { 10 }

      buffer = Curlybars::SafeBuffer.new('*' * 5)

      expect do
        buffer.safe_concat('*' * 5)
      end.not_to raise_error
    end

    it "raises when (buffer length + the existing output lenght) > output_limit" do
      allow(configuration).to receive(:output_limit) { 10 }
      buffer = Curlybars::SafeBuffer.new('*' * 10)

      expect do
        buffer.safe_concat('*')
      end.to raise_error(Curlybars::Error::Render)
    end

    it "raises when buffer length > output_limit" do
      allow(configuration).to receive(:output_limit) { 10 }

      expect do
        Curlybars::SafeBuffer.new.safe_concat('*' * 11)
      end.to raise_error(Curlybars::Error::Render)
    end
  end
end
