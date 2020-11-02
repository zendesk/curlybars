describe Curlybars::TypeInferrer do
  it "returns the dependency tree updated with the inferred types" do
    source = <<~HBS
      {{#each (a (b (c collection)))}}
        {{attr}}
      {{/each}}
    HBS

    dependency_tree = {
      a: [:helper, [{}]],
      b: [:helper, [{}]],
      c: [:helper, [{}]],
      collection: [{ attr: nil }]
    }

    inferred_tree = described_class.new(source).infer_from(dependency_tree)

    expect(inferred_tree).to include(
      a: [{ attr: nil }],
      b: [{ attr: nil }],
      c: [{ attr: nil }],
      collection: [{ attr: nil }]
    )
  end

  it "raises a validation error when the first argument of a generic collection helper is not a collection" do
    begin
      source = <<~HBS
        {{#each (a (b (c collection)))}}
          {{attr}}
        {{/each}}
      HBS

      dependency_tree = {
        a: [:helper, [{}]],
        b: [:helper, [{}]],
        c: [:helper, [{}]],
        collection: { attr: nil }
      }

      described_class.new(source).infer_from(dependency_tree)
    rescue Curlybars::Error::Validate => e
      expect(e.id).to eq 'validate.unallowed_path'
    end
  end

  it "raises a validation error when the generic collection helper does not have any arguments" do
    begin
      source = <<~HBS
        {{#each (a (b (c)))}}
          {{attr}}
        {{/each}}
      HBS

      dependency_tree = {
        a: [:helper, [{}]],
        b: [:helper, [{}]],
        c: [:helper, [{}]]
      }

      described_class.new(source).infer_from(dependency_tree)
    rescue Curlybars::Error::Validate => e
      expect(e.id).to eq 'validate.missing_path'
    end
  end

  it "raises a validation error when the generic collection helper's first argument is not defined" do
    begin
      source = <<~HBS
        {{#each (a (b (c collection)))}}
          {{attr}}
        {{/each}}
      HBS

      dependency_tree = {
        a: [:helper, [{}]],
        b: [:helper, [{}]],
        c: [:helper, [{}]]
      }

      described_class.new(source).infer_from(dependency_tree)
    rescue Curlybars::Error::Validate => e
      expect(e.id).to eq 'validate.unallowed_path'
    end
  end
end
