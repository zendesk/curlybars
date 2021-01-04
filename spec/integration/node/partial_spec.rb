describe "{{> partial}}" do
  let(:global_helpers_providers) { [] }

  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "evaluates the methods chain call" do
      template = Curlybars.compile(<<-HBS)
        {{> partial}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        partial
      HTML
    end

    it "renders nothing when the partial returns `nil`" do
      template = Curlybars.compile(<<-HBS)
        {{> return_nil}}
      HBS

      expect(eval(template)).to resemble("")
    end
  end

  describe "#validate" do
    it "validates the path with errors" do
      dependency_tree = {}

      source = <<-HBS
        {{> unallowed_partial}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "raises when using a helper as a partial" do
      dependency_tree = { helper: nil }

      source = <<-HBS
        {{> helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "does not raise with a valid partial" do
      dependency_tree = { partial: :partial }

      source = <<-HBS
        {{> partial}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end
  end
end
