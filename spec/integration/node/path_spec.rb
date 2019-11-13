describe "{{path}}" do
  let(:global_helpers_providers) { [] }

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

    it "is tolerant to paths that return `nil`" do
      template = Curlybars.compile(<<-HBS)
        {{return_nil.property}}
      HBS

      expect(eval(template)).to resemble("")
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

    it "{{-a-path-}} is a valid path" do
      template = Curlybars.compile(<<-HBS)
        {{-a-path-}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        a path, whose name contains underscores
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

    it "understands `length` as allowed method on a collection" do
      template = Curlybars.compile(<<-HBS)
        {{array_of_users.length}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        1
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
      dependency_tree = { sub_context: {}, outer_field: nil }

      source = <<-HBS
        {{#with sub_context}}
          {{../outer_field}}
        {{/with}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "gives errors errors when it goes out of context" do
      dependency_tree = {}

      source = <<-HBS
        {{../outer_field}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "without errors using `this`" do
      dependency_tree = { field: nil }

      source = <<-HBS
        {{#with this}}
          {{field}}
        {{/with}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "without errors using `length` on a collection of presenters" do
      dependency_tree = { collection_of_presenters: [{}] }

      source = <<-HBS
        {{collection_of_presenters.length}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "with errors using `length` on anything else than a collection" do
      dependency_tree = { presenter: {} }

      source = <<-HBS
        {{presenter.length}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "with errors when adding another step after `length`" do
      dependency_tree = { presenter: {} }

      source = <<-HBS
        {{presenter.length.anything}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "to refer an outer scope using `this`" do
      dependency_tree = { field: nil, sub_presenter: {} }

      source = <<-HBS
        {{#with sub_presenter}}
          {{#with ../this}}
            {{field}}
          {{/with}}
        {{/with}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    describe "with errors" do
      it "raises with errors" do
        dependency_tree = {}
        errors = Curlybars.validate(dependency_tree, "{{unallowed_path}}")

        expect(errors).not_to be_empty
      end

      it "raises with metadata" do
        dependency_tree = {}
        errors = Curlybars.validate(dependency_tree, "{{unallowed_path}}")

        expect(errors.first.metadata).to eq(path: "unallowed_path", step: :unallowed_path)
      end

      it "raises with length 0 when the error has no length" do
        dependency_tree = {}
        errors = Curlybars.validate(dependency_tree, "{{ok}")

        expect(errors.first.position).to eq(Curlybars::Position.new(nil, 1, 4, 0))
      end

      describe "raises correct error message" do
        let(:dependency_tree) { { ok: nil } }

        it "when path contains several parts" do
          source = "{{ok.unallowed.ok}}"
          errors = Curlybars.validate(dependency_tree, source)

          expect(errors.first.message).to eq("not possible to access `unallowed` in `ok.unallowed.ok`")
        end

        it "when path contains one part" do
          source = "{{unallowed}}"
          errors = Curlybars.validate(dependency_tree, source)

          expect(errors.first.message).to eq("'unallowed' does not exist")
        end
      end

      it "with errors when going outside of scope" do
        dependency_tree = { ok: { ok: { ok: nil } } }

        source = <<~HBS
          {{../ok.ok.ok}}
        HBS

        errors = Curlybars.validate(dependency_tree, source)

        expect(errors.first.message).to eq("'../ok.ok.ok' goes out of scope")
      end

      describe "raises exact location of unallowed steps" do
        let(:dependency_tree) { { ok: { allowed: { ok: nil } } } }

        it "when in a compacted form" do
          source = "{{ok.unallowed.ok}}"
          errors = Curlybars.validate(dependency_tree, source)

          expect(errors.first.position).to eq(Curlybars::Position.new(nil, 1, 5, 12))
        end

        it "with `this` keyword" do
          source = "{{ok.this.unallowed.ok}}"
          errors = Curlybars.validate(dependency_tree, source)

          expect(errors.first.position).to eq(Curlybars::Position.new(nil, 1, 10, 12))
        end

        it "with some spacing" do
          source = "   {{ ok.unallowed.ok    }}  "
          errors = Curlybars.validate(dependency_tree, source)

          expect(errors.first.position).to eq(Curlybars::Position.new(nil, 1, 9, 12))
        end
      end
    end
  end
end
