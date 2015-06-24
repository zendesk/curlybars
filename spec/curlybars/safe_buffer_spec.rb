describe Curlybars::SafeBuffer do
  let(:configuration) { double(:configuration) }

  before do
    allow(Curlybars).to receive(:configuration) { configuration }
  end

  describe '#is_a?' do
    it "is a String" do
      expect(Curlybars::SafeBuffer.new.is_a?(String)).to be_truthy
    end

    it "is a ActiveSupport::SafeBuffer" do
      expect(Curlybars::SafeBuffer.new.is_a?(ActiveSupport::SafeBuffer)).to be_truthy
    end
  end

  describe "#concat" do
    it "accepts when (buffer length + the existing output lenght) <= output_limit" do
      allow(configuration).to receive(:output_limit) { 10 }

      buffer = Curlybars::SafeBuffer.new('*' * 5)

      expect do
        buffer.concat('*' * 5)
      end.not_to raise_error
    end

    it "raises when (buffer length + the existing output lenght) > output_limit" do
      allow(configuration).to receive(:output_limit) { 10 }
      buffer = Curlybars::SafeBuffer.new('*' * 10)

      expect do
        buffer.concat('*')
      end.to raise_error(Curlybars::Error::Render)
    end

    it "raises when buffer length > output_limit" do
      allow(configuration).to receive(:output_limit) { 10 }

      expect do
        Curlybars::SafeBuffer.new.concat('*' * 11)
      end.to raise_error(Curlybars::Error::Render)
    end
  end
end
