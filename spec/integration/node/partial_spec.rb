describe "{{> partial}}" do
  let(:global_helpers_providers) { [] }

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
    let(:global_helpers_providers) { [IntegrationTest::PartialResolvingProvider.new] }

    after do
      Thread.current[:curlybars_partial_depth] = nil
      Thread.current[:curlybars_render_start_time] = nil
    end

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

      # Should not infinite-loop; stops at depth limit and returns empty string
      expect(eval(template)).to resemble("")
    ensure
      Curlybars.reset
    end

    it "falls back to presenter method when resolver returns nil" do
      template = Curlybars.compile(<<-HBS)
        {{> partial}}
      HBS

      # 'partial' is not in PartialResolvingProvider::PARTIALS, so falls back to presenter method
      expect(eval(template)).to resemble(<<-HTML)
        partial
      HTML
    end

    # --- Object passing tests ---

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

    # --- Error protection tests ---

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

    # --- Timeout propagation test ---

    it "propagates parent start_time to child partials via thread-local" do
      Curlybars.configuration.rendering_timeout = 10

      template = Curlybars.compile(<<-HBS)
        {{> card title="timeout"}}
      HBS

      # Inject an old start_time via thread-local; root.rb reads it and
      # passes to RenderingSupport, which then propagates it to partials.
      Thread.current[:curlybars_render_start_time] = Time.now - 20

      expect { eval(template) }.to raise_error(Curlybars::Error::Render)
    ensure
      Thread.current[:curlybars_render_start_time] = nil
      Curlybars.reset
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
  end
end
