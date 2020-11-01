describe "tilde operator" do
  let(:global_helpers_providers) { [] }

  describe "compilation" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "{{~ ... }} removes trailing whitespaces and newlines from the previous :TEXT" do
      template = Curlybars.compile("before \r\t\n{{~'curlybars'}}\n\t\r after")

      expect(eval(template)).to resemble("beforecurlybars\n\t\r after")
    end

    it "{{ ... ~}} removes trailing whitespaces and newlines from the next :TEXT" do
      template = Curlybars.compile("before \r\t\n{{'curlybars'~}}\n\t\r after")

      expect(eval(template)).to resemble("before \r\t\ncurlybarsafter")
    end

    it "{{~ ... ~}} does not remove trailing whitespaces and newlines from the next :TEXT" do
      template = Curlybars.compile("before \r\t\n{{~'curlybars'~}}\n\t\r after")

      expect(eval(template)).to resemble("beforecurlybarsafter")
    end
  end

  describe "validation" do
    let(:presenter) { double(:presenter, dependency_tree: { curlybars: nil }) }

    it "runs even when 'run_processors' flag is set to false" do
      allow(Curlybars::Processor::Tilde).to receive(:process!)

      Curlybars.validate(presenter.dependency_tree, "source", run_processors: false)

      expect(Curlybars::Processor::Tilde).to have_received(:process!).twice
    end
  end
end
