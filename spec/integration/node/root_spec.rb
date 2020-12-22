describe "root" do
  describe "#validate" do
    it "without errors if template is empty" do
      dependency_tree = {}

      source = ""

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end
  end
end
