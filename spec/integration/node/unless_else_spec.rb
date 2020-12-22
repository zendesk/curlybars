describe "{{#unless}}...{{else}}...{{/unless}}" do
  let(:global_helpers_providers) { [] }

  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "renders the unless_template" do
      allow(presenter).to receive(:allows_method?).with(:condition).and_return(true)
      allow(presenter).to receive(:condition).and_return(false)

      template = Curlybars.compile(<<-HBS)
        {{#unless condition}}
          unless_template
        {{else}}
          else_template
        {{/unless}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        unless_template
      HTML
    end

    it "renders the else_template" do
      allow(presenter).to receive(:allows_method?).with(:condition).and_return(true)
      allow(presenter).to receive(:condition).and_return(true)

      template = Curlybars.compile(<<-HBS)
        {{#unless condition}}
          unless_template
        {{else}}
          else_template
        {{/unless}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        else_template
      HTML
    end

    it "allows empty else_template" do
      allow(presenter).to receive(:allows_method?).with(:valid).and_return(true)
      allow(presenter).to receive(:valid).and_return(false)

      template = Curlybars.compile(<<-HBS)
        {{#unless valid}}
          unless_template
        {{else}}{{/unless}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        unless_template
      HTML
    end

    it "allows empty unless_template" do
      allow(presenter).to receive(:allows_method?).with(:valid).and_return(true)
      allow(presenter).to receive(:valid).and_return(true)

      template = Curlybars.compile(<<-HBS)
        {{#unless valid}}{{else}}
          else_template
        {{/unless}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        else_template
      HTML
    end

    it "allows empty unless_template and else_template" do
      allow(presenter).to receive(:allows_method?).with(:valid).and_return(true)
      allow(presenter).to receive(:valid).and_return(false)

      template = Curlybars.compile(<<-HBS)
        {{#unless valid}}{{else}}{{/unless}}
      HBS

      expect(eval(template)).to resemble("")
    end
  end

  describe "#validate" do
    it "validates with errors the condition" do
      dependency_tree = {}

      source = <<-HBS
        {{#unless condition}}{{else}}{{/unless}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "validates without errors when using a helper in the condition" do
      dependency_tree = { helper: :helper }

      source = <<-HBS
        {{#unless helper}}{{/unless}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "validates with errors the nested unless_template" do
      dependency_tree = { condition: nil }

      source = <<-HBS
        {{#unless condition}}
          {{unallowed_method}}
        {{else}}
        {{/unless}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "validates with errors the nested else_template" do
      dependency_tree = { condition: nil }

      source = <<-HBS
        {{#unless condition}}
        {{else}}
          {{unallowed_method}}
        {{/unless}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end
  end
end
