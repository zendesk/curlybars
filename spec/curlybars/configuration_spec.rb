describe Curlybars::Configuration do
  after do
    Curlybars.reset
  end

  describe "#presenters_namespace" do
    it "defaults to an empty string" do
      presenters_namespace = Curlybars::Configuration.new.presenters_namespace

      expect(presenters_namespace).to eq('')
    end
  end

  describe "#presenters_namespace=" do
    it "can set value" do
      config = Curlybars::Configuration.new
      config.presenters_namespace = 'foo'
      expect(config.presenters_namespace).to eq('foo')
    end
  end

  describe "#custom_processors" do
    it "can set value" do
      config = Curlybars::Configuration.new
      config.custom_processors = ['test']
      expect(config.custom_processors).to eq(['test'])
    end
  end

  describe ".configure" do
    before do
      Curlybars.configure do |config|
        config.presenters_namespace = 'bar'
      end
    end

    it "returns correct value for presenters_namespace" do
      presenters_namespace = Curlybars.configuration.presenters_namespace

      expect(presenters_namespace).to eq('bar')
    end
  end

  describe ".reset" do
    it "resets the configuration to default value" do
      Curlybars.configure do |config|
        config.presenters_namespace = 'foobarbaz'
      end

      Curlybars.reset

      presenters_namespace = Curlybars.configuration.presenters_namespace

      expect(presenters_namespace).to eq('')
    end
  end
end
