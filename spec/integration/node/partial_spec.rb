describe "{{> partial}}" do
  let(:global_helpers_providers) { [] }
  let(:partial_provider) { nil }

  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "evaluates the methods chain call" do
      template = Curlybars.compile(<<-HBS)
        {{> partial}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        partial
      HTML
    end

    it "renders nothing when the partial returns `nil`" do
      template = Curlybars.compile(<<-HBS)
        {{> return_nil}}
      HBS

      expect(eval(template)).to resemble("")
    end
  end

  describe "#compile with resolver" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }
    let(:partial_provider) { IntegrationTest::PartialResolvingProvider.new }

    it "renders a resolved partial template" do
      template = Curlybars.compile(<<-HBS)
        {{> card title="Hello"}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        <div class="card">Hello</div>
      HTML
    end

    it "passes options to the partial as template variables" do
      template = Curlybars.compile(<<-HBS)
        {{> card title="World"}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        <div class="card">World</div>
      HTML
    end

    it "renders nested partials" do
      template = Curlybars.compile(<<-HBS)
        {{> nested_outer}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        inner
      HTML
    end

    it "enforces nesting depth limit" do
      Curlybars.configuration.partial_nesting_limit = 3

      template = Curlybars.compile(<<-HBS)
        {{> deeply_nested}}
      HBS

      expect(eval(template)).to resemble("")
    ensure
      Curlybars.reset
    end

    it "falls back to presenter method when resolver returns nil" do
      template = Curlybars.compile(<<-HBS)
        {{> partial}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        partial
      HTML
    end

    it "passes a presenter as an option" do
      template = Curlybars.compile(<<-HBS)
        {{> user_card user=user}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        <span>Libo</span>
      HTML
    end

    it "passes a presenter via `this` inside #with" do
      template = Curlybars.compile(<<-HBS)
        {{#with user}}{{> user_card user=this}}{{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        <span>Libo</span>
      HTML
    end

    it "supports deep traversal inside a partial" do
      template = Curlybars.compile(<<-HBS)
        {{> article_section article=article}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        <article>The Prince by Nicolò</article>
      HTML
    end

    it "passes values from #each via option" do
      template = Curlybars.compile(<<-HBS)
        {{#each two_elements}}{{> simple_name name=first_name}}{{/each}}
      HBS

      expect(eval(template)).to resemble("LiboLibo")
    end

    it "passes a dotted path as an option" do
      template = Curlybars.compile(<<-HBS)
        {{> user_card user=article.author}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        <span>Nicolò</span>
      HTML
    end

    it "passes a user presenter as comment option" do
      template = Curlybars.compile(<<-HBS)
        {{> comment_item comment=user}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        <li>Libo</li>
      HTML
    end

    it "renders a resolved partial with no options" do
      template = Curlybars.compile(<<-HBS)
        {{> nested_inner}}
      HBS

      expect(eval(template)).to resemble("inner")
    end

    it "renders empty string when option is missing (no crash)" do
      template = Curlybars.compile(<<-HBS)
        {{> user_card}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "renders empty string for malformed partial source" do
      template = Curlybars.compile(<<-HBS)
        {{> malformed}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "renders empty string when referencing undefined data in partial" do
      template = Curlybars.compile(<<-HBS)
        {{> missing_ref}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "propagates timeout error from nested partial (not swallowed)" do
      Curlybars.configuration.rendering_timeout = 10

      template = Curlybars.compile(<<-HBS)
        {{> nested_outer}}
      HBS

      rendering_context = { start_time: Time.now - 20, depth: 0 } # rubocop:disable Lint/UselessAssignment -- read by eval'd template via defined?(rendering_context)

      expect { eval(template) }.to raise_error(Curlybars::Error::Render).with_message(/too long/)
    ensure
      Curlybars.reset
    end

    it "propagates parent start_time to child partials via rendering_context" do
      Curlybars.configuration.rendering_timeout = 10

      template = Curlybars.compile(<<-HBS)
        {{> card title="timeout"}}
      HBS

      rendering_context = { start_time: Time.now - 20, depth: 0 } # rubocop:disable Lint/UselessAssignment -- read by eval'd template via defined?(rendering_context)

      expect { eval(template) }.to raise_error(Curlybars::Error::Render)
    ensure
      Curlybars.reset
    end

    context "with global helper provider" do
      let(:global_helpers_providers) { [IntegrationTest::GlobalHelperProvider.new] }

      it "can access global helpers inside a partial" do
        template = Curlybars.compile(<<-HBS)
          {{> global_helper_partial title="test"}}
        HBS

        expect(eval(template)).to resemble("testtest")
      end
    end

    it "passes `this` from #each to a partial" do
      template = Curlybars.compile(<<-HBS)
        {{#each two_elements}}{{> user_card user=this}}{{/each}}
      HBS

      expect(eval(template)).to resemble("<span>Libo</span><span>Libo</span>")
    end

    it "passes parent scope value via ../ inside #with" do
      template = Curlybars.compile(<<-HBS)
        {{#with user}}{{> card title=../article.title}}{{/with}}
      HBS

      expect(eval(template)).to resemble('<div class="card">The Prince</div>')
    end

    it "passes parent scope value via ../ inside #each" do
      template = Curlybars.compile(<<-HBS)
        {{#each two_elements}}{{> simple_name name=../article.title}}{{/each}}
      HBS

      expect(eval(template)).to resemble("The PrinceThe Prince")
    end

    it "propagates output_too_long error from partial" do
      Curlybars.configuration.output_limit = 50

      template = Curlybars.compile(<<-HBS)
        {{> big_output}}
      HBS

      expect { eval(template) }.to raise_error(Curlybars::Error::Render).with_message(/too long/)
    ensure
      Curlybars.reset
    end

    it "returns empty string for self-referencing partial (no infinite loop)" do
      template = Curlybars.compile(<<-HBS)
        {{> self_ref}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "renders the same partial multiple times with different options" do
      template = Curlybars.compile(<<-HBS)
        {{> card title="A"}}{{> card title="B"}}
      HBS

      expect(eval(template)).to resemble('<div class="card">A</div><div class="card">B</div>')
    end

    it "renders a partial inside #if" do
      template = Curlybars.compile(<<-HBS)
        {{#if valid}}{{> card title="yes"}}{{/if}}
      HBS

      expect(eval(template)).to resemble('<div class="card">yes</div>')
    end

    it "does not render a partial inside #unless when truthy" do
      template = Curlybars.compile(<<-HBS)
        {{#unless valid}}{{> card title="no"}}{{/unless}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "forwards string literal through nested partials" do
      template = Curlybars.compile(<<-HBS)
        {{> outer_card title="Hi"}}
      HBS

      expect(eval(template)).to resemble("<outer><inner>Hi</inner></outer>")
    end

    it "forwards a presenter through nested partials" do
      template = Curlybars.compile(<<-HBS)
        {{> outer_user user=user}}
      HBS

      expect(eval(template)).to resemble("<outer><inner>Libo</inner></outer>")
    end

    it "forwards a dotted path through nested partials" do
      template = Curlybars.compile(<<-HBS)
        {{> outer_author article=article}}
      HBS

      expect(eval(template)).to resemble("<outer><inner>Nicolò</inner></outer>")
    end

    it "forwards `this` through nested partials inside #with" do
      template = Curlybars.compile(<<-HBS)
        {{#with user}}{{> outer_user user=this}}{{/with}}
      HBS

      expect(eval(template)).to resemble("<outer><inner>Libo</inner></outer>")
    end

    it "forwards ../ through nested partials inside #each" do
      template = Curlybars.compile(<<-HBS)
        {{#each two_elements}}{{> outer_card title=../article.title}}{{/each}}
      HBS

      expect(eval(template)).to resemble(
        "<outer><inner>The Prince</inner></outer><outer><inner>The Prince</inner></outer>"
      )
    end
  end

  describe "#validate" do
    it "does not raise errors for any partial path (lenient validation)" do
      dependency_tree = {}

      source = <<-HBS
        {{> unknown_partial}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "validates options" do
      dependency_tree = { partial: :partial }

      source = <<-HBS
        {{> partial title="Hello"}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "allows a presenter (Hash) as an option value" do
      dependency_tree = { user: { first_name: nil } }

      source = <<-HBS
        {{> avatar user=user}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "reports a single error when only one option path is out of scope" do
      dependency_tree = { user: { first_name: nil } }

      source = <<-HBS
        {{> avatar user=user foo=nonexistent_xyzzy}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors.length).to eq(1)
    end

    it "identifies the out-of-scope path in the error message" do
      dependency_tree = { user: { first_name: nil } }

      source = <<-HBS
        {{> avatar user=user foo=nonexistent_xyzzy}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors.first.message).to match(/nonexistent_xyzzy/)
    end
  end

  describe "#validate with resolver" do
    let(:resolver) do
      lambda { |name|
        {
          'card' => '<div class="card">{{title}}</div>',
          'user_card' => '<span>{{user.first_name}}</span>',
          'nested_outer' => '{{> nested_inner title="hi"}}',
          'nested_inner' => '{{title}}',
          'deeply_nested' => '{{> deeply_nested}}',
          'missing_ref' => '{{subtitle}}'
        }[name]
      }
    end

    it "reports no errors when partial options match partial content" do
      dependency_tree = {}

      source = <<-HBS
        {{> card title="Hello"}}
      HBS

      errors = Curlybars.validate(dependency_tree, source, partial_resolver: resolver)

      expect(errors).to be_empty
    end

    it "reports an error when the partial references data it does not receive", :aggregate_failures do
      dependency_tree = {}

      source = <<-HBS
        {{> missing_ref}}
      HBS

      errors = Curlybars.validate(dependency_tree, source, partial_resolver: resolver)

      expect(errors.length).to eq(1)
      expect(errors.first.message).to match(/subtitle/)
    end

    it "sets position.file_name to the partial identifier on partial errors", :aggregate_failures do
      dependency_tree = {}

      source = <<-HBS
        {{> missing_ref}}
      HBS

      errors = Curlybars.validate(dependency_tree, source, partial_resolver: resolver)

      expect(errors.length).to eq(1)
      expect(errors.first.position.file_name).to eq(:'partials/missing_ref')
    end

    it "validates nested paths when a presenter is passed as an option" do
      dependency_tree = { user: { first_name: nil } }

      source = <<-HBS
        {{> user_card user=user}}
      HBS

      errors = Curlybars.validate(dependency_tree, source, partial_resolver: resolver)

      expect(errors).to be_empty
    end

    it "validates nested partials recursively" do
      dependency_tree = {}

      source = <<-HBS
        {{> nested_outer}}
      HBS

      errors = Curlybars.validate(dependency_tree, source, partial_resolver: resolver)

      expect(errors).to be_empty
    end

    it "reports an error for a self-referencing partial", :aggregate_failures do
      dependency_tree = {}

      source = <<-HBS
        {{> deeply_nested}}
      HBS

      errors = Curlybars.validate(dependency_tree, source, :parent_template, partial_resolver: resolver)

      expect(errors.length).to eq(1)
      expect(errors.first.message).to match(/deeply_nested.*cannot reference itself/)
      expect(errors.first.position.file_name).to eq(:'partials/deeply_nested')
    end

    it "prevents infinite recursion of indirect cycles via depth limit" do
      Curlybars.configuration.partial_nesting_limit = 3

      cycle_resolver = lambda { |name|
        { 'ping' => '{{> pong}}', 'pong' => '{{> ping}}' }[name]
      }

      dependency_tree = {}

      source = <<-HBS
        {{> ping}}
      HBS

      errors = Curlybars.validate(dependency_tree, source, partial_resolver: cycle_resolver)

      expect(errors).to be_empty
    ensure
      Curlybars.reset
    end

    it "falls back to presenter-based partial check when resolver returns nil" do
      dependency_tree = { partial: :partial }

      source = <<-HBS
        {{> partial}}
      HBS

      errors = Curlybars.validate(dependency_tree, source, partial_resolver: resolver)

      expect(errors).to be_empty
    end

    it "reports an error when resolver returns nil and path is not a partial in the tree", :aggregate_failures do
      dependency_tree = { user: { first_name: nil } }

      source = <<-HBS
        {{> unknown_partial}}
      HBS

      errors = Curlybars.validate(dependency_tree, source, partial_resolver: resolver)

      expect(errors.length).to eq(1)
      expect(errors.first.message).to match(/partial/)
    end

    it "validates ../ in partial options inside #with" do
      dependency_tree = { user: { first_name: nil }, article: { title: nil } }

      source = <<-HBS
        {{#with user}}{{> card title=../article.title}}{{/with}}
      HBS

      resolver_with_card = lambda { |name|
        { 'card' => '<div class="card">{{title}}</div>' }[name]
      }

      errors = Curlybars.validate(dependency_tree, source, partial_resolver: resolver_with_card)

      expect(errors).to be_empty
    end

    it "validates `this` in partial options inside #each" do
      dependency_tree = { articles: [{ title: nil }] }

      source = <<-HBS
        {{#each articles}}{{> card title=this.title}}{{/each}}
      HBS

      resolver_with_card = lambda { |name|
        { 'card' => '<div class="card">{{title}}</div>' }[name]
      }

      errors = Curlybars.validate(dependency_tree, source, partial_resolver: resolver_with_card)

      expect(errors).to be_empty
    end

    it "is lenient when no resolver is provided (existing behavior)" do
      dependency_tree = {}

      source = <<-HBS
        {{> unknown_partial}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end
  end
end
