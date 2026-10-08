class GatedGlobalHelpers
  extend Curlybars::MethodWhitelist

  allow_methods do |context, method_allower|
    method_allower.call(:always_allowed, reflect: [Curlybars::Generic])
    if context&.theming_api_version.to_i >= 4
      method_allower.call(json: Curlybars::Generic)
      method_allower.call(:legacy_json)
    end
  end

  def initialize(context = nil)
    @context = context
  end

  def always_allowed
    'always'
  end

  def reflect(collection, _)
    collection
  end

  def legacy_json
    'legacy'
  end

  def json(value, _)
    value.to_s
  end
end

class CountingGlobalHelpers < GatedGlobalHelpers
  class << self
    attr_accessor :dependency_tree_calls
  end

  class << self
    def dependency_tree(context = nil)
      self.dependency_tree_calls = dependency_tree_calls.to_i + 1
      super
    end
  end
end

class FakeValidationContext
  attr_reader :partial_resolver, :depth, :theming_api_version

  def initialize(theming_api_version:, partial_resolver: nil, depth: 0)
    @theming_api_version = theming_api_version
    @partial_resolver = partial_resolver
    @depth = depth
  end

  def valid?
    depth < Curlybars.configuration.partial_nesting_limit
  end

  def increment_depth
    self.class.new(theming_api_version: theming_api_version, partial_resolver: partial_resolver, depth: depth + 1)
  end
end

RSpec.describe 'context-aware global helpers' do
  let(:context) { FakeValidationContext.new(theming_api_version: theming_api_version) }
  let(:theming_api_version) { 4 }

  before do
    Curlybars.configure do |config|
      config.global_helpers_provider_classes = [GatedGlobalHelpers]
    end
    Curlybars.instance_variable_set(:@global_helpers_dependency_tree, nil)
  end

  after do
    Curlybars.reset
    Curlybars.instance_variable_set(:@global_helpers_dependency_tree, nil)
  end

  def validate(source, dependency_tree = {}, validation_context: context)
    Curlybars.validate(dependency_tree, source, validation_context: validation_context)
  end

  describe "gated generic helper" do
    context "when theming_api_version satisfies the gate" do
      it "validates {{json x}} without errors" do
        expect(validate('{{json x}}', { x: nil })).to be_empty
      end

      it "validates {{legacy_json}} without errors" do
        expect(validate('{{legacy_json}}')).to be_empty
      end

      it "resolves the global at nested depth" do
        expect(validate('{{#with article}}{{json title}}{{/with}}', { article: { title: nil } })).to be_empty
      end
    end

    context "when theming_api_version does not satisfy the gate" do
      let(:theming_api_version) { 3 }

      it "raises unallowed_path for {{legacy_json}}" do
        error = validate('{{legacy_json}}').first

        expect(error.id).to eq('validate.unallowed_path')
      end

      it "raises unallowed_path for {{json x}}" do
        error = validate('{{json x}}', { x: nil }).first

        expect(error.id).to eq('validate.unallowed_path')
      end

      it "raises unallowed_path for the global at nested depth" do
        error = validate('{{#with article}}{{json title}}{{/with}}', { article: { title: nil } }).first

        expect(error.id).to eq('validate.unallowed_path')
      end
    end
  end

  describe "gated bare helper in a subexpression" do
    context "when theming_api_version satisfies the gate" do
      it "validates without errors" do
        expect(validate('{{#if (legacy_json)}} ... {{/if}}')).to be_empty
      end
    end

    context "when theming_api_version does not satisfy the gate" do
      let(:theming_api_version) { 3 }

      it "raises unallowed_path" do
        error = validate('{{#if (legacy_json)}} ... {{/if}}').first

        expect(error.id).to eq('validate.unallowed_path')
      end
    end
  end

  describe "gated generic helper used as a subexpression head" do
    it "is rejected even when the gate is satisfied" do
      error = validate('{{#if (json x)}} ... {{/if}}', { x: nil }).first

      expect(error.id).to eq('validate.not_a_helper')
    end
  end

  describe "gated generic helper nested in a subexpression option" do
    let(:dependency_tree) { { items: [{ name: nil }] } }
    let(:source) { '{{#each (reflect items equals=(json "x"))}}{{name}}{{/each}}' }

    context "when theming_api_version does not satisfy the gate" do
      let(:theming_api_version) { 3 }

      it "surfaces unallowed_path from the gated option" do
        error = validate(source, dependency_tree).first

        expect(error.id).to eq('validate.unallowed_path')
      end
    end
  end

  describe "gates are inherited by partials" do
    let(:context) do
      FakeValidationContext.new(
        theming_api_version: theming_api_version,
        partial_resolver: ->(name) { name == 'json_partial' ? '{{json x}}' : nil }
      )
    end

    context "when theming_api_version satisfies the gate" do
      it "validates the partial without errors" do
        expect(validate('{{> json_partial x=x}}', { x: nil })).to be_empty
      end
    end

    context "when theming_api_version does not satisfy the gate" do
      let(:theming_api_version) { 3 }

      it "raises unallowed_path from inside the partial" do
        error = validate('{{> json_partial x=x}}', { x: nil }).first

        expect(error.id).to eq('validate.unallowed_path')
      end
    end
  end

  describe "without a validation context" do
    it "keeps the ungated helper available with no presenter-tree entry" do
      errors = Curlybars.validate({}, '{{always_allowed}}')

      expect(errors).to be_empty
    end

    it "keeps the gated helper out of the static tree" do
      errors = Curlybars.validate({ x: nil }, '{{json x}}')

      expect(errors.first.id).to eq('validate.unallowed_path')
    end
  end

  describe "shadowing parity" do
    it "lets the global shadow a presenter method of the same name at nested depth" do
      dependency_tree = { article: { json: nil, title: nil } }
      source = '{{#with article}}{{json title}}{{/with}}'

      ungated_errors = validate(source, dependency_tree, validation_context: FakeValidationContext.new(theming_api_version: 3))

      expect(ungated_errors.first.id).to eq('validate.invalid_signature')
    end

    it "resolves the shadowing global at nested depth when gated" do
      dependency_tree = { article: { json: nil, title: nil } }
      source = '{{#with article}}{{json title}}{{/with}}'

      gated_errors = validate(source, dependency_tree, validation_context: FakeValidationContext.new(theming_api_version: 4))

      expect(gated_errors).to be_empty
    end
  end

  describe "memoization" do
    before do
      Curlybars.configure do |config|
        config.global_helpers_provider_classes = [CountingGlobalHelpers]
      end
      CountingGlobalHelpers.dependency_tree_calls = 0
    end

    it "computes the contextual tree once per context instance" do
      dependency_tree = { x: nil }

      Curlybars.validate(dependency_tree, '{{json x}}', validation_context: context)
      Curlybars.validate(dependency_tree, '{{json}}', validation_context: context)
      Curlybars.validate(dependency_tree, '{{json x}}', validation_context: FakeValidationContext.new(theming_api_version: 4))

      expect(CountingGlobalHelpers.dependency_tree_calls).to eq(2)
    end

    it "computes the static tree once per process" do
      Curlybars.validate({ x: nil }, '{{json x}}')
      Curlybars.validate({ x: nil }, '{{json x}}')

      expect(CountingGlobalHelpers.dependency_tree_calls).to eq(1)
    end
  end
end
