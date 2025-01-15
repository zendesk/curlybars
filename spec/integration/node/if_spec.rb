describe "{{#if}}...{{/if}}" do
  let(:global_helpers_providers) { [] }

  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "returns positive branch when condition is true" do
      allow(presenter).to receive(:allows_method?).with(:valid).and_return(true)
      allow(presenter).to receive(:valid).and_return(true)

      template = Curlybars.compile(<<-HBS)
        {{#if valid}}
          if_template
        {{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        if_template
      HTML
    end

    it "doesn't return positive branch when condition is false" do
      allow(presenter).to receive(:allows_method?).with(:valid).and_return(true)
      allow(presenter).to receive(:valid).and_return(false)

      template = Curlybars.compile(<<-HBS)
        {{#if valid}}
          if_template
        {{/if}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "doesn't return positive branch when condition is empty array" do
      allow(presenter).to receive(:allows_method?).with(:collection).and_return(true)
      allow(presenter).to receive(:collection).and_return([])

      template = Curlybars.compile(<<-HBS)
        {{#if collection}}
          if_template
        {{/if}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "works with nested `if blocks` (double positive)" do
      allow(presenter).to receive(:allows_method?).with(:valid).and_return(true)
      allow(presenter).to receive(:allows_method?).with(:visible).and_return(true)
      allow(presenter).to receive_messages(valid: true, visible: true)

      template = Curlybars.compile(<<-HBS)
        {{#if valid}}
          {{#if visible}}
            inner_if_template
          {{/if}}
          outer_if_template
        {{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        inner_if_template
        outer_if_template
      HTML
    end

    it "works with nested `if blocks` (positive and negative)" do
      allow(presenter).to receive(:allows_method?).with(:valid).and_return(true)
      allow(presenter).to receive(:allows_method?).with(:visible).and_return(true)
      allow(presenter).to receive_messages(valid: true, visible: false)

      template = Curlybars.compile(<<-HBS)
        {{#if valid}}
          {{#if visible}}
            inner_if_template
          {{/if}}
          outer_if_template
        {{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        outer_if_template
      HTML
    end

    it "allows empty if_template" do
      allow(presenter).to receive(:allows_method?).with(:valid).and_return(true)
      allow(presenter).to receive(:valid).and_return(true)

      template = Curlybars.compile(<<-HBS)
        {{#if valid}}{{/if}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "allows usage of variables in condition" do
      template = Curlybars.compile(<<-HBS)
        {{#each two_elements}}
          {{#if @first}}I am the first!{{/if}}
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        I am the first!
      HTML
    end
  end

  describe "#validate" do
    it "validates with errors the condition" do
      dependency_tree = {}

      source = <<-HBS
        {{#if condition}}{{/if}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "validates with errors the nested template" do
      dependency_tree = { condition: nil }

      source = <<-HBS
        {{#if condition}}
          {{unallowed_method}}
        {{/if}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "validates without errors the helper as condition" do
      dependency_tree = { helper: :helper }

      source = <<-HBS
        {{#if helper}}{{/if}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end
  end
end
