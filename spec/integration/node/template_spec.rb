describe "template" do
  let(:global_helpers_providers) { [] }

  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "raises an exception when contexts stack is too deep (>= 10)" do
      template = Curlybars.compile(hbs_with_depth(10))

      expect do
        eval(template)
      end.to raise_error(Curlybars::Error::Render)
    end

    it "raises an exception when contexts stack is not too deep (< 10)" do
      template = Curlybars.compile(hbs_with_depth(9))

      expect do
        eval(template)
      end.not_to raise_error
    end

    it "can be empty" do
      template = Curlybars.compile('')

      expect(eval(template)).to resemble("")
    end

    it "can contain a single curly" do
      template = Curlybars.compile('{')

      expect(eval(template)).to resemble(<<-HTML)
        {
      HTML
    end

    it "can contain a single backslash" do
      template = Curlybars.compile('\\')

      expect(eval(template)).to resemble(<<-HTML)
        \\
      HTML
    end

    private

    def hbs_with_depth(depth)
      hbs = "%s"
      depth.times { hbs %= "{{#with this}}%s{{/with}}" }
      hbs %= ''
    end
  end

  describe "#validate" do
    it "without errors" do
      dependency_tree = { presenter: { field: nil } }

      source = <<-HBS
        {{#with presenter}}
          {{field}}
        {{/with}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "with errors" do
      dependency_tree = { presenter: { field: nil } }

      source = <<-HBS
        {{#with presenter}}
          {{unallowed}}
        {{/with}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end
  end
end
