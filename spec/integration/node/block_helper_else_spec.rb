describe "{{#helper arg1 arg2 ... key=value ...}}...<{{else}}>...{{/helper}}" do
  let(:global_helpers_providers) { [IntegrationTest::GlobalHelperProvider.new] }

  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "can be a global helper" do
      template = Curlybars.compile(<<-HBS)
        {{global_helper 'argument' option='value'}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        argument - option:value
      HTML
    end

    it "accepts no arguments at all" do
      template = Curlybars.compile(<<-HBS)
        {{#just_yield}}
          template
        {{/just_yield}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        template
      HTML
    end

    it "passes two arguments" do
      template = Curlybars.compile(<<-HBS)
        {{#print_args_and_options 'first' 'second'}}
        {{/print_args_and_options}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        first, second, key=
      HTML
    end

    it "passes two arguments and options" do
      template = Curlybars.compile(<<-HBS)
        {{#print_args_and_options 'first' 'second' key='value'}}
        {{/print_args_and_options}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        first, second, key=value
      HTML
    end

    it "renders the inverse block" do
      template = Curlybars.compile(<<-HBS)
        {{#render_inverse}}
          fn
        {{else}}
          inverse
        {{/render_inverse}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        inverse
      HTML
    end

    it "renders the fn block" do
      template = Curlybars.compile(<<-HBS)
        {{#render_fn}}
          fn
        {{else}}
          inverse
        {{/render_fn}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        fn
      HTML
    end

    it "block helpers can access the current context" do
      template = Curlybars.compile(<<-HBS)
        {{#print_current_context}} {{/print_current_context}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        root_context
      HTML
    end

    it "renders a block helper without options" do
      template = Curlybars.compile(<<-HBS)
        {{#beautify}}
          template
        {{/beautify}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        bold template italic
      HTML
    end

    it "renders a block helper with custom variables" do
      template = Curlybars.compile(<<-HBS)
        {{#yield_custom_variable}}
          {{!--
            `@custom1` and `@custom2` are variables yielded
            by the block helper implementation.
          --}}

          {{@custom1}} {{@custom2}}
        {{/yield_custom_variable}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        custom variable1
        custom variable2
      HTML
    end

    it "renders a block helper with custom variables that can be used in conditionals" do
      template = Curlybars.compile(<<-HBS)
        {{#yield_custom_variable}}
          {{!--
            `@cond` is a boolean variable yielded
            by the block helper implementation.
          --}}

          {{#if @cond}}
            Cond is true
          {{/if}}
        {{/yield_custom_variable}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        Cond is true
      HTML
    end

    it "renders a block helper with custom variables that can be seen by nested contexts" do
      template = Curlybars.compile(<<-HBS)
        {{#yield_custom_variable}}
          {{!--
            `@custom1` and `@custom2` are variables yielded
            by the block helper implementation.
          --}}
          {{#with this}}
            {{@custom1}} {{@custom2}}
          {{/with}}
        {{/yield_custom_variable}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        custom variable1
        custom variable2
      HTML
    end

    it "renders a block helper with options and presenter" do
      template = Curlybars.compile(<<-HBS)
        {{#form new_comment_form class="red" foo="bar"}}
          {{new_comment_form.button_label}}
        {{/form}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        beauty class:red foo:bar submit
      HTML
    end

    it "allow empty template" do
      template = Curlybars.compile(<<-HBS)
        {{#form new_comment_form class="red" foo="bar"}}{{/form}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        beauty class:red foo:bar
      HTML
    end

    it "renders correctly a return type of integer" do
      template = Curlybars.compile(<<-HBS)
        {{#integer new_comment_form}} text {{/integer}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        0
      HTML
    end

    it "renders correctly a return type of boolean" do
      template = Curlybars.compile(<<-HBS)
        {{#boolean new_comment_form}} text {{/boolean}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        true
      HTML
    end

    it "accepts a nil context" do
      template = Curlybars.compile(<<-HBS)
        {{#this_method_yields return_nil}}
        {{/this_method_yields}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "yield tolerated nil as pushed context" do
      template = Curlybars.compile(<<-HBS)
        {{#this_method_yields return_nil}}
          text
        {{/this_method_yields}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        text
      HTML
    end

    it "raises an exception if the context is not a presenter-like object" do
      template = Curlybars.compile(<<-HBS)
        {{#boolean post}} text {{/boolean}}
      HBS

      expect do
        eval(template)
      end.to raise_error(Curlybars::Error::Render)
    end
  end

  describe "#validate" do
    it "without errors when global helper" do
      allow(Curlybars.configuration).to receive(:global_helpers_provider_classes).and_return([IntegrationTest::GlobalHelperProvider])

      dependency_tree = {}

      source = <<-HBS
        {{global_helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "without errors when invoking a leaf" do
      dependency_tree = { name: nil }

      source = <<-HBS
        {{name}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "without errors if argument is a leaf" do
      dependency_tree = { block_helper: :helper, argument: nil }

      source = <<-HBS
        {{#block_helper argument}} ... {{/block_helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "without errors if argument is a literal" do
      dependency_tree = { block_helper: :helper }

      source = <<-HBS
        {{#block_helper 'argument'}} ... {{/block_helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "without errors if argument is a variable" do
      dependency_tree = { block_helper: :helper }

      source = <<-HBS
        {{#block_helper @var}} ... {{/block_helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "without errors if option is a leaf" do
      dependency_tree = { block_helper: :helper, argument: nil }

      source = <<-HBS
        {{#block_helper option=argument}} ... {{/block_helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "without errors if option is a literal" do
      dependency_tree = { block_helper: :helper }

      source = <<-HBS
        {{#block_helper option='argument'}} ... {{/block_helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "without errors if option is a variable" do
      dependency_tree = { block_helper: :helper }

      source = <<-HBS
        {{#block_helper option=@var}} ... {{/block_helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "without errors in block_helper" do
      dependency_tree = { block_helper: :helper, context: nil }

      source = <<-HBS
        {{#block_helper context}} ... {{/block_helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "with errors when invoking a leaf with arguments" do
      dependency_tree = { name: nil }

      source = <<-HBS
        {{name 'argument'}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "with errors when invoking a leaf with options" do
      dependency_tree = { name: nil }

      source = <<-HBS
        {{name option='value'}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "with errors if argument is not a value" do
      dependency_tree = { block_helper: :helper, not_a_value: {} }

      source = <<-HBS
        {{#block_helper not_a_value}} ... {{/block_helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "with errors if option is not a value" do
      dependency_tree = { block_helper: :helper, not_a_value: {} }

      source = <<-HBS
        {{#block_helper option=not_a_value}} ... {{/block_helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "with errors in fn block" do
      dependency_tree = { context: {}, block_helper: :helper }

      source = <<-HBS
        {{#block_helper context}}
          {{invalid}}
        {{/block_helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "with errors in inverse block" do
      dependency_tree = { context: {}, block_helper: :helper }

      source = <<-HBS
        {{#block_helper context}}
        {{else}}
          {{invalid}}
        {{/block_helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end
  end
end
