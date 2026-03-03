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
