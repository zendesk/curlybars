describe "{{#if}}...{{else}}...{{/if}}" do
  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "renders the if_template" do
      allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:return_true) { true }
      allow(presenter).to receive(:return_true) { true }

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
      allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:return_false) { true }
      allow(presenter).to receive(:return_false) { false }

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
      allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:valid) { true }
      allow(presenter).to receive(:valid) { false }

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
      allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:valid) { true }
      allow(presenter).to receive(:valid) { true }

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
      allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:valid) { true }
      allow(presenter).to receive(:valid) { true }

      template = Curlybars.compile(<<-HBS)
        {{#if valid}}{{else}}{{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
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
        {{#if condition}}{{else}}{{/if}}
      HBS

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).not_to be_empty
    end

    it "vaidates with errors the nested if_template" do
      allow(presenter_class).to receive(:dependency_tree) do
        { condition: nil }
      end

      source = <<-HBS
        {{#if condition}}
          {{unallowed_method}}
        {{else}}
        {{/if}}
      HBS

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).not_to be_empty
    end

    it "vaidates with errors the nested if_template" do
      allow(presenter_class).to receive(:dependency_tree) do
        { condition: nil }
      end

      source = <<-HBS
        {{#if condition}}
        {{else}}
          {{unallowed_method}}
        {{/if}}
      HBS

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).not_to be_empty
    end
  end
end
