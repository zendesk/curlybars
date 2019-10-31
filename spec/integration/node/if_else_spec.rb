describe "{{#if}}...{{else}}...{{/if}}" do
  let(:global_helpers_providers) { [] }

  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "renders the if_template" do
      allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:return_true).and_return(true)
      allow(presenter).to receive(:return_true).and_return(true)

      template = Curlybars.compile(<<-HBS)
        {{#if return_true}}
          if_template
        {{else}}
          else_template
        {{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        if_template
      HTML
    end

    it "renders the else_template" do
      allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:return_false).and_return(true)
      allow(presenter).to receive(:return_false).and_return(false)

      template = Curlybars.compile(<<-HBS)
        {{#if return_false}}
          if_template
        {{else}}
          else_template
        {{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        else_template
      HTML
    end

    it "allows empty if_template" do
      allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:valid).and_return(true)
      allow(presenter).to receive(:valid).and_return(false)

      template = Curlybars.compile(<<-HBS)
      {{#if valid}}{{else}}
        else_template
      {{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        else_template
      HTML
    end

    it "allows empty else_template" do
      allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:valid).and_return(true)
      allow(presenter).to receive(:valid).and_return(true)

      template = Curlybars.compile(<<-HBS)
        {{#if valid}}
          if_template
        {{else}}{{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        if_template
      HTML
    end

    it "allows empty if_template and else_template" do
      allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:valid).and_return(true)
      allow(presenter).to receive(:valid).and_return(true)

      template = Curlybars.compile(<<-HBS)
        {{#if valid}}{{else}}{{/if}}
      HBS

      expect(eval(template)).to resemble("")
    end
  end

  describe "#validate" do
    let(:presenter_class) { double(:presenter_class) }

    it "validates without errors the literal condition" do
      dependency_tree = {}

      source = <<-HBS
        {{#if 42}}{{else}}{{/if}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "validates with errors the condition" do
      dependency_tree = {}

      source = <<-HBS
        {{#if condition}}{{else}}{{/if}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "validates with errors the nested if_template" do
      dependency_tree = { condition: nil }

      source = <<-HBS
        {{#if condition}}
          {{unallowed_method}}
        {{else}}
        {{/if}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "validates with errors the nested else_template" do
      dependency_tree = { condition: nil }

      source = <<-HBS
        {{#if condition}}
        {{else}}
          {{unallowed_method}}
        {{/if}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "validates errors the nested else_template when out of context" do
      dependency_tree = { condition: nil }

      source = <<-HBS
        {{#if ../condition}}
        {{else}}
          {{unallowed_ELSE_method}}
        {{/if}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors.count).to eq(2)
    end

    it "gives all possible errors found in validation" do
      dependency_tree = { condition: nil }

      source = <<-HBS
        {{#if ../condition}}
          {{unallowed_IF_method}}
        {{else}}
          {{unallowed_ELSE_method}}
        {{/if}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors.count).to eq(3)
    end
  end
end
