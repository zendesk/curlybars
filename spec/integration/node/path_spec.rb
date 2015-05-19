describe "{{path}}" do
  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "evaluates the methods chain call" do
      template = Curlybars.compile(<<-HBS)
        {{user.avatar.url}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        http://example.com/foo.png
      HTML
    end

    it "{{../path}} is evaluated on the second to last context in the stack" do
      template = Curlybars.compile(<<-HBS)
        {{#with user.avatar}}
          {{../context}}
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        root_context
      HTML
    end

    it "{{../../path}} is evaluated on the third to last context in the stack" do
      template = Curlybars.compile(<<-HBS)
        {{#with user}}
          {{#with avatar}}
            {{../../context}}
          {{/with}}
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        root_context
      HTML
    end

    it "{{../path}} uses the right context, even when using the same name" do
      template = Curlybars.compile(<<-HBS)
        {{#with user}}
          {{#with avatar}}
            {{../context}}
          {{/with}}
          {{../context}}
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        user_context
        root_context
      HTML
    end

    it "a path with more `../` than the stack size will resolve to empty string" do
      template = Curlybars.compile(<<-HBS)
        {{context}}
        {{../context}}
        {{../../context}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        root_context
      HTML
    end

    it "understands `this` as the current presenter" do
      template = Curlybars.compile(<<-HBS)
        {{user.avatar.url}}
        {{#with this}}
          {{user.avatar.url}}
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        http://example.com/foo.png
        http://example.com/foo.png
      HTML
    end

    it "understands `../this` as the outer presenter" do
      template = Curlybars.compile(<<-HBS)
        {{#with user.avatar}}
          {{../context}}
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        root_context
      HTML
    end

    it "raises when trying to call methods not implemented on context" do
      template = Curlybars.compile(<<-HBS)
        {{not_in_whitelist}}
      HBS

      expect do
        eval(eval(template))
      end.to raise_error(Curlybars::Error::Render)
    end
  end

  describe "#validate" do
    let(:presenter_class) { double(:presenter_class) }

    it "without errors" do
      allow(presenter_class).to receive(:dependency_tree) do
        { sub_context: {}, outer_field: nil }
      end

      source = <<-HBS
        {{#with sub_context}}
          {{../outer_field}}
        {{/with}}
      HBS

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).to be_empty
    end

    it "without errors when it's a deprecated component" do
      allow(presenter_class).to receive(:dependency_tree) do
        { deprecated: :deprecated }
      end

      source = <<-HBS
        {{deprecated}}
      HBS

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).to be_empty
    end

    it "without errors when it goes out of context" do
      allow(presenter_class).to receive(:dependency_tree) do
        {}
      end

      source = <<-HBS
        {{../outer_field}}
      HBS

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).to be_empty
    end

    it "without errors using `this`" do
      allow(presenter_class).to receive(:dependency_tree) do
        { field: nil }
      end

      source = <<-HBS
        {{#with this}}
          {{field}}
        {{/with}}
      HBS

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).to be_empty
    end

    it "to refer an outer scope using `this`" do
      allow(presenter_class).to receive(:dependency_tree) do
        { field: nil, sub_presenter: {} }
      end

      source = <<-HBS
        {{#with sub_presenter}}
          {{#with ../this}}
            {{field}}
          {{/with}}
        {{/with}}
      HBS

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).to be_empty
    end

    describe "with errors" do
      let(:source) { "{{unallowed_path}}" }

      before do
        allow(presenter_class).to receive(:dependency_tree) { {} }
      end

      it "raises with errors" do
        errors = Curlybars.validate(presenter_class, source)

        expect(errors).not_to be_empty
      end

      it "raises with metadata" do
        errors = Curlybars.validate(presenter_class, source)

        expect(errors.first.metadata).to eq(path: "unallowed_path", step: :unallowed_path)
      end
    end
  end
end
