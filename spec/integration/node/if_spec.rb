describe "{{#if}}...{{/if}}" do
  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "returns positive branch when condition is true" do
      allow(presenter).to receive(:allows_method?).with(:valid) { true }
      allow(presenter).to receive(:valid) { true }

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
      allow(presenter).to receive(:allows_method?).with(:valid) { true }
      allow(presenter).to receive(:valid) { false }

      template = Curlybars.compile(<<-HBS)
        {{#if valid}}
          if_template
        {{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
      HTML
    end

    it "doesn't return positive branch when condition is empty array" do
      allow(presenter).to receive(:allows_method?).with(:collection) { true }
      allow(presenter).to receive(:collection) { [] }

      template = Curlybars.compile(<<-HBS)
        {{#if collection}}
          if_template
        {{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
      HTML
    end

    it "works with nested `if blocks` (double positive)" do
      allow(presenter).to receive(:allows_method?).with(:valid) { true }
      allow(presenter).to receive(:allows_method?).with(:visible) { true }
      allow(presenter).to receive(:valid) { true }
      allow(presenter).to receive(:visible) { true }

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
      allow(presenter).to receive(:allows_method?).with(:valid) { true }
      allow(presenter).to receive(:allows_method?).with(:visible) { true }
      allow(presenter).to receive(:valid) { true }
      allow(presenter).to receive(:visible) { false }

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
      allow(presenter).to receive(:allows_method?).with(:valid) { true }
      allow(presenter).to receive(:valid) { true }

      template = Curlybars.compile(<<-HBS)
        {{#if valid}}{{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
      HTML
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
    let(:presenter_class) { double(:presenter_class) }

    it "vaidates with errors the condition" do
      allow(presenter_class).to receive(:dependency_tree) do
        {}
      end

      source = <<-HBS
        {{#if condition}}{{/if}}
      HBS

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).not_to be_empty
    end

    it "vaidates with errors the nested template" do
      allow(presenter_class).to receive(:dependency_tree) do
        { condition: nil }
      end

      source = <<-HBS
        {{#if condition}}
          {{unallowed_method}}
        {{/if}}
      HBS

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).not_to be_empty
    end
  end
end
