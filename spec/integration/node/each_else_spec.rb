describe "{{#each collection}}...{{else}}...{{/each}}" do
  let(:global_helpers_providers) { [IntegrationTest::GlobalHelperProvider.new] }

  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter_class) { IntegrationTest::Presenter }
    let(:presenter) { presenter_class.new(double("view_context"), post: post) }

    it "uses each_template when collection is not empty" do
      allow(presenter).to receive(:allows_method?).with(:non_empty_collection).and_return(true)
      allow(presenter).to receive(:non_empty_collection) { [presenter] }

      template = Curlybars.compile(<<-HBS)
        {{#each non_empty_collection}}
          each_template
        {{else}}
          else_template
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        each_template
      HTML
    end

    it "uses else_template when collection is empty" do
      allow(presenter).to receive(:allows_method?).with(:empty_collection).and_return(true)
      allow(presenter).to receive(:empty_collection).and_return([])

      template = Curlybars.compile(<<-HBS)
        {{#each empty_collection}}
          each_template
        {{else}}
          else_template
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        else_template
      HTML
    end

    it "renders {{path}} when collection is not empty" do
      path_presenter_class = Class.new(Curlybars::Presenter) do
        presents :path
        allow_methods :path
        def path
          @path
        end
      end

      a_path_presenter = path_presenter_class.new(nil, path: 'a_path')
      another_path_presenter = path_presenter_class.new(nil, path: 'another_path')

      allow(presenter).to receive(:allows_method?).with(:non_empty_collection).and_return(true)
      allow(presenter).to receive(:non_empty_collection) { [a_path_presenter, another_path_presenter] }

      template = Curlybars.compile(<<-HBS)
        {{#each non_empty_collection}}
          {{path}}
        {{else}}
          else_template
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        a_path
        another_path
      HTML
    end

    it "allows empty each_template" do
      allow(presenter).to receive(:allows_method?).with(:empty_collection).and_return(true)
      allow(presenter).to receive(:empty_collection).and_return([])

      template = Curlybars.compile(<<-HBS)
        {{#each empty_collection}}{{else}}
          else_template
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        else_template
      HTML
    end

    it "allows empty else_template" do
      allow(presenter).to receive(:allows_method?).with(:non_empty_collection).and_return(true)
      allow(presenter).to receive(:non_empty_collection) { [presenter] }

      template = Curlybars.compile(<<-HBS)
        {{#each non_empty_collection}}
          each_template
        {{else}}{{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        each_template
      HTML
    end

    it "allows empty each_template and else_template" do
      allow(presenter).to receive(:allows_method?).with(:non_empty_collection).and_return(true)
      allow(presenter).to receive(:non_empty_collection) { [presenter] }

      template = Curlybars.compile(<<-HBS)
        {{#each non_empty_collection}}{{else}}{{/each}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "renders nothing if the context is nil" do
      template = Curlybars.compile(<<-HBS)
        {{#each return_nil}}
          each_template
        {{else}}
          else_template
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        else_template
      HTML
    end

    it "allows subexpressions" do
      template = Curlybars.compile(<<-HBS)
        {{#each (articles)}}left{{else}}right{{/each}}
      HBS

      expected = "left" * presenter.articles.size
      expect(eval(template)).to resemble(expected)
    end

    it "allows subexpressions with collection helpers" do
      template = Curlybars.compile(<<-HBS)
        {{#each (reverse_articles)}}
          {{title}}
        {{else}}
          right
        {{/each}}
      HBS

      expected = presenter.reverse_articles.inject("") { |res, a| res + a.title }
      expect(eval(template)).to resemble(expected)
    end

    it "allows subexpressions with generic collection helpers" do
      template = Curlybars.compile(<<-HBS)
        {{#each (refl articles)}}
          {{title}}
        {{else}}
          right
        {{/each}}
      HBS

      expected = presenter.articles.inject("") { |res, a| res + a.title }
      expect(eval(template)).to resemble(expected)
    end

    it "raises an error if the context is not an array-like object" do
      allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:not_a_collection).and_return(true)
      allow(presenter).to receive(:not_a_collection).and_return("string")

      template = Curlybars.compile(<<-HBS)
        {{#each not_a_collection}}{{else}}{{/each}}
      HBS

      expect do
        eval(template)
      end.to raise_error(Curlybars::Error::Render)
    end

    it "raises an error if the objects inside of the context array are not presenters" do
      allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:not_a_presenter_collection).and_return(true)
      allow(presenter).to receive(:not_a_presenter_collection).and_return([:an_element])

      template = Curlybars.compile(<<-HBS)
        {{#each not_a_presenter_collection}}{{else}}{{/each}}
      HBS

      expect do
        eval(template)
      end.to raise_error(Curlybars::Error::Render)
    end
  end

  describe "#validate" do
    it "without errors" do
      dependency_tree = { a_presenter_collection: [{}] }

      source = <<-HBS
        {{#each a_presenter_collection}} {{else}} {{/each}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "with errors due to a presenter path" do
      dependency_tree = { a_presenter: {} }

      source = <<-HBS
        {{#each a_presenter}} {{else}} {{/each}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "with errors due to a leaf path" do
      dependency_tree = { a_leaf: nil }

      source = <<-HBS
        {{#each a_leaf}} {{else}} {{/each}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "with errors due unallowed method" do
      dependency_tree = {}

      source = <<-HBS
        {{#each unallowed}} {{else}} {{/each}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    describe "with subexpressions" do
      before do
        Curlybars.instance_variable_set(:@global_helpers_dependency_tree, nil)
      end

      it "without errors when called with a presenter collection" do
        dependency_tree = { a_presenter_collection: [{}] }

        source = <<-HBS
          {{#each (a_presenter_collection)}} {{else}} {{/each}}
        HBS

        errors = Curlybars.validate(dependency_tree, source)

        expect(errors).to be_empty
      end

      it "without errors when called with a collection helper" do
        dependency_tree = { a_collection_helper: [:helper, [{ url: nil }]] }

        source = <<-HBS
          {{#each (a_collection_helper)}}
            {{url}}
          {{else}}
            right
          {{/each}}
        HBS

        errors = Curlybars.validate(dependency_tree, source)

        expect(errors).to be_empty
      end

      context "with a generic collection helper" do
        it "without errors when arguments are valid" do
          dependency_tree = {
            refl: [:helper, [{}]],
            articles: [{ url: nil }]
          }

          source = <<-HBS
            {{#each (refl articles)}}
              {{url}}
            {{else}}
              right
            {{/each}}
          HBS

          errors = Curlybars.validate(dependency_tree, source)

          expect(errors).to be_empty
        end

        it "with errors when the first argument is not a collection" do
          dependency_tree = {
            refl: [:helper, [{}]],
            articles: { url: nil }
          }

          source = <<-HBS
            {{#each (refl articles)}}
              {{url}}
            {{else}}
              right
            {{/each}}
          HBS

          errors = Curlybars.validate(dependency_tree, source)

          expect(errors).not_to be_empty
        end

        it "with errors when the first argument is not defined" do
          dependency_tree = {
            refl: [:helper, [{}]]
          }

          source = <<-HBS
            {{#each (refl articles)}}
              {{url}}
            {{else}}
              right
            {{/each}}
          HBS

          errors = Curlybars.validate(dependency_tree, source)

          expect(errors).not_to be_empty
        end

        it "with errors when no argument is given" do
          dependency_tree = {
            refl: [:helper, [{}]]
          }

          source = <<-HBS
            {{#each (refl)}}
              {{url}}
            {{else}}
              right
            {{/each}}
          HBS

          errors = Curlybars.validate(dependency_tree, source)

          expect(errors).not_to be_empty
        end

        describe "as a global helper" do
          let(:global_helpers_provider_classes) { [IntegrationTest::GlobalHelperProvider] }

          before do
            allow(Curlybars.configuration).to receive(:global_helpers_provider_classes).and_return(global_helpers_provider_classes)
          end

          it "without errors when the first argument is a collection" do
            dependency_tree = {
              articles: [{ url: nil }]
            }

            source = <<-HBS
              {{#each (slice articles 0 4)}}
                {{url}}
              {{else}}
                right
              {{/each}}
            HBS

            errors = Curlybars.validate(dependency_tree, source)

            expect(errors).to be_empty
          end

          it "with errors when the first argument is not a collection" do
            dependency_tree = {
              articles: { url: nil }
            }

            source = <<-HBS
              {{#each (slice articles 0 4)}}
                {{url}}
              {{else}}
                right
              {{/each}}
            HBS

            errors = Curlybars.validate(dependency_tree, source)

            expect(errors).not_to be_empty
          end

          it "with errors when no argument is given" do
            dependency_tree = {}

            source = <<-HBS
              {{#each (slice)}}
                {{url}}
              {{else}}
                right
              {{/each}}
            HBS

            errors = Curlybars.validate(dependency_tree, source)

            expect(errors).not_to be_empty
          end
        end
      end
    end
  end
end
