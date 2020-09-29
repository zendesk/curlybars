describe "{{helper context key=value}}" do
  let(:global_helpers_providers) { [] }

  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "passes two arguments" do
      template = Curlybars.compile(<<-HBS)
        {{print_args_and_options 'first' 'second'}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        first, second, key=
      HTML
    end

    it "calls a helper without arguments in an if statement" do
      template = Curlybars.compile(<<-HBS)
        {{#if print_args_and_options}}
          {{print_args_and_options 'first' 'second'}}
        {{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        first, second, key=
      HTML
    end

    it "passes two arguments and options" do
      template = Curlybars.compile(<<-HBS)
        {{print_args_and_options 'first' 'second' key='value'}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        first, second, key=value
      HTML
    end

    it "renders a helper with expression and options" do
      template = Curlybars.compile(<<-HBS)
        {{date user.created_at class='metadata'}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        <time datetime="2015-02-03T13:25:06Z" class="metadata">
          February 3, 2015 13:25
        </time>
      HTML
    end

    it "renders a helper with only expression" do
      template = Curlybars.compile(<<-HBS)
        <script src="{{asset "jquery_plugin.js"}}"></script>
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        <script src="http://cdn.example.com/jquery_plugin.js"></script>
      HTML
    end

    it "renders a helper with only options" do
      template = Curlybars.compile(<<-HBS)
        {{#with new_comment_form}}
          {{input title class="form-control"}}
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        <input name="community_post[title]"
          id="community_post_title"
          type="text"
          class="form-control"
          value="some value persisted in the DB">
      HTML
    end

    it "renders correctly a return type of integer" do
      template = Curlybars.compile(<<-HBS)
        {{integer 'ignored'}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        0
      HTML
    end

    it "renders correctly a return type of boolean" do
      template = Curlybars.compile(<<-HBS)
        {{boolean 'ignored'}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        true
      HTML
    end

    it "handles correctly a method that invokes `yield`, returning empty string" do
      template = Curlybars.compile(<<-HBS)
        {{this_method_yields}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "doesn't render if the path returns a presenter" do
      template = Curlybars.compile(<<-HBS)
        {{user}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "doesn't render if the path returns a collection of presenters" do
      template = Curlybars.compile(<<-HBS)
        {{array_of_users}}
      HBS

      expect(eval(template)).to resemble("")
    end
  end

  describe "#validate" do
    let(:presenter_class) { double(:presenter_class) }

    it "with errors" do
      dependency_tree = {}

      source = <<-HBS
        {{helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "raises when using a partial as an helper" do
      dependency_tree = { partial: :partial }

      source = <<-HBS
        {{partial}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "without errors" do
      dependency_tree = { helper: :helper }

      source = <<-HBS
        {{helper}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "validates {{helper.invoked_on_nil}} with errors" do
      dependency_tree = { helper: :helper }

      source = <<-HBS
        {{helper.invoked_on_nil}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    describe "with context" do
      it "without errors in block_helper" do
        dependency_tree = { helper: :helper, context: nil }

        source = <<-HBS
          {{helper context}}
        HBS

        errors = Curlybars.validate(dependency_tree, source)

        expect(errors).to be_empty
      end
    end
  end
end
