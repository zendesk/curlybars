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

      raise "Should have raised but it returned"
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

      raise "Should have raised but it returned"
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

      raise "Should have raised but it returned"
    rescue Curlybars::Error::Validate => e
      expect(e.id).to eq 'validate.unallowed_path'
    end
  end

  context "with generic collection helpers as global helpers" do
    let(:global_helpers_provider_classes) { [IntegrationTest::GlobalHelperProvider] }

    before do
      Curlybars.instance_variable_set(:@global_helpers_dependency_tree, nil)
      allow(Curlybars.configuration).to receive(:global_helpers_provider_classes).and_return(global_helpers_provider_classes)
    end

    it "returns the dependency tree updated with the inferred types" do
      source = <<~HBS
        {{#each (slice (b (c collection)))}}
          {{attr}}
        {{/each}}
      HBS

      dependency_tree = {
        b: [:helper, [{}]],
        c: [:helper, [{}]],
        collection: [{ attr: nil }]
      }

      inferred_tree = described_class.new(source).infer_from(dependency_tree)

      expect(inferred_tree).to include(
        b: [{ attr: nil }],
        c: [{ attr: nil }],
        collection: [{ attr: nil }]
      )
    end

    it "raises a validation error when the generic collection helper's first argument is not defined" do
      begin
        source = <<~HBS
          {{#each (slice collection)}}
            {{attr}}
          {{/each}}
        HBS

        dependency_tree = {}

        described_class.new(source).infer_from(dependency_tree)

        raise "Should have raised but it returned"
      rescue Curlybars::Error::Validate => e
        expect(e.id).to eq 'validate.unallowed_path'
      end
    end

    it "raises a validation error when the generic collection helper does not have any arguments" do
      begin
        source = <<~HBS
          {{#each (slice)}}
            {{attr}}
          {{/each}}
        HBS

        dependency_tree = {}

        described_class.new(source).infer_from(dependency_tree)

        raise "Should have raised but it returned"
      rescue Curlybars::Error::Validate => e
        expect(e.id).to eq 'validate.missing_path'
      end
    end

    it "raises a validation error when the first argument of a generic collection helper is not a collection" do
      begin
        source = <<~HBS
          {{#each (slice not_a_collection)}}
            {{attr}}
          {{/each}}
        HBS

        dependency_tree = {
          not_a_collection: { attr: nil }
        }

        described_class.new(source).infer_from(dependency_tree)

        raise "Should have raised but it returned"
      rescue Curlybars::Error::Validate => e
        expect(e.id).to eq 'validate.unallowed_path'
      end
    end
  end
end
