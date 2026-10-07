describe "{{json arg}} serialization backstops" do
  let(:global_helpers_providers) { [IntegrationTest::GlobalHelperProvider.new] }
  let(:partial_provider) { nil }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context")) }

  around do |example|
    original = Curlybars.configuration.output_limit
    example.run
    Curlybars.configuration.output_limit = original
  end

  it "aborts with output_too_long once serialization exceeds the budget" do
    Curlybars.configuration.output_limit = 10
    template = Curlybars.compile("{{json articles}}")

    expect { eval(template) }.
      to raise_error(an_instance_of(Curlybars::Error::Render).and(having_attributes(id: 'render.output_too_long')))
  end

  it "aborts with nesting_too_deep on a reference cycle" do
    template = Curlybars.compile("{{json cyclic}}")

    expect { eval(template) }.
      to raise_error(an_instance_of(Curlybars::Error::Render).and(having_attributes(id: 'render.nesting_too_deep')))
  end

  it "serializes normally when within the budget" do
    template = Curlybars.compile("{{json article.title}}")

    expect(eval(template)).to eq('"The Prince"')
  end

  context "when inside a partial" do
    let(:partial_provider) { IntegrationTest::PartialResolvingProvider.new }

    it "propagates nesting_too_deep out of the partial (not swallowed)" do
      template = Curlybars.compile("{{> cyclic_json node=cyclic}}")

      expect { eval(template) }.
        to raise_error(an_instance_of(Curlybars::Error::Render).and(having_attributes(id: 'render.nesting_too_deep')))
    end
  end
end
