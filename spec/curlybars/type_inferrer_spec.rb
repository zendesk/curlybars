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
end
