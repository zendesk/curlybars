describe "processors" do
  let(:presenter) { double(:presenter, dependency_tree: { curlybars: nil }) }
  let(:processor) { double(:processor) }

  before do
    allow(Curlybars.configuration).to receive(:custom_processors).and_return([processor])
    allow(processor).to receive(:process!)
  end

  describe "validation" do
    it "are run twice by default" do
      Curlybars.validate(presenter.dependency_tree, "source")

      expect(processor).to have_received(:process!).twice
    end

    it "are run twice when run_processors is true" do
      Curlybars.validate(presenter.dependency_tree, "source", run_processors: true)

      expect(processor).to have_received(:process!).twice
    end

    it "are run once when run_processors is false" do
      Curlybars.validate(presenter.dependency_tree, "source", run_processors: false)

      expect(processor).to have_received(:process!).once
    end
  end
end
