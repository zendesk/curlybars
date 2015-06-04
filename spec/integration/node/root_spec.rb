describe "root" do
  describe "#validate" do
    let(:presenter_class) { double(:presenter_class) }

    it "without errors if template is empty" do
      allow(presenter_class).to receive(:dependency_tree) { {} }

      source = ""

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).to be_empty
    end
  end
end
