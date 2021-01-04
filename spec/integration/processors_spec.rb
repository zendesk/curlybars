describe "processors" do
  let(:presenter) { double(:presenter, dependency_tree: { curlybars: nil }) }
  let(:processor) { double(:processor) }

  before do
    allow(Curlybars.configuration).to receive(:custom_processors).and_return([processor])
    allow(processor).to receive(:process!)
  end

  describe "validation" do
    it "are run by default" do
      Curlybars.validate(presenter, "source")

      expect(processor).to have_received(:process!)
    end

    it "are not run when run_processors is true" do
      Curlybars.validate(presenter, "source", run_processors: true)

      expect(processor).to have_received(:process!)
    end

    it "are not run when run_processors is false" do
      Curlybars.validate(presenter, "source", run_processors: false)

      expect(processor).not_to have_received(:process!)
    end
  end
end
