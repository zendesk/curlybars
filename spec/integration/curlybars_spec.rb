describe Curlybars do
  let(:presenter_class) { double(:presenter_class) }

  describe ".validate" do
    describe "validates {{helper}}" do
      it "with errors" do
        allow(presenter_class).to receive(:dependency_tree) do
          {}
        end

        source = <<-HBS
          {{helper}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).not_to be_empty
      end

      it "without errors" do
        allow(presenter_class).to receive(:dependency_tree) do
          { helper: nil }
        end

        source = <<-HBS
          {{helper}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).to be_empty
      end

      it "validates {{helper.invoked_on_nil}} with errors" do
        allow(presenter_class).to receive(:dependency_tree) do
          { helper: nil }
        end

        source = <<-HBS
          {{helper.invoked_on_nil}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).not_to be_empty
      end

      it "validates {{helper.data}} without errors" do
        allow(presenter_class).to receive(:dependency_tree) do
          { helper: { data: nil } }
        end

        source = <<-HBS
          {{helper.data}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).to be_empty
      end

      it "validates {{helper.data.missing}} with errors" do
        allow(presenter_class).to receive(:dependency_tree) do
          { helper: { data: nil } }
        end

        source = <<-HBS
          {{helper.data.missing}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).not_to be_empty
      end
    end

    describe "validates {{#with}}" do
      it "without errors" do
        allow(presenter_class).to receive(:dependency_tree) do
          { a_presenter: {} }
        end

        source = <<-HBS
          {{#with a_presenter}}{{/with}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).to be_empty
      end

      it "with errors due to a leaf" do
        allow(presenter_class).to receive(:dependency_tree) do
          { not_a_presenter: nil }
        end

        source = <<-HBS
          {{#with not_a_presenter}}{{/with}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).not_to be_empty
      end

      it "with errors due unallowed method" do
        allow(presenter_class).to receive(:dependency_tree) do
          {}
        end

        source = <<-HBS
          {{#with unallowed}}{{/with}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).not_to be_empty
      end
    end

    describe "validates {{#each}}" do
      it "without errors" do
        allow(presenter_class).to receive(:dependency_tree) do
          { a_presenter_collection: [{}] }
        end

        source = <<-HBS
          {{#each a_presenter_collection}}{{/each}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).to be_empty
      end

      it "with errors due to a presenter path" do
        allow(presenter_class).to receive(:dependency_tree) do
          { a_presenter: {} }
        end

        source = <<-HBS
          {{#each a_presenter}}{{/each}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).not_to be_empty
      end

      it "with errors due to a leaf path" do
        allow(presenter_class).to receive(:dependency_tree) do
          { a_leaf: nil }
        end

        source = <<-HBS
          {{#each a_leaf}}{{/each}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).not_to be_empty
      end

      it "with errors due unallowed method" do
        allow(presenter_class).to receive(:dependency_tree) do
          {}
        end

        source = <<-HBS
          {{#each unallowed}}{{/each}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).not_to be_empty
      end
    end

    describe "validates {{#block_helper context}} ... {{/block_helper}}" do
      it "without errors in context" do
        allow(presenter_class).to receive(:dependency_tree) do
          { context: {}, block_helper: nil }
        end

        source = <<-HBS
          {{#block_helper context}} ... {{/block_helper}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).to be_empty
      end

      it "with errors in context" do
        allow(presenter_class).to receive(:dependency_tree) do
          { context: {}, block_helper: nil }
        end

        source = <<-HBS
          {{#block_helper no_a_presenter}} ... {{/block_helper}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).not_to be_empty
      end

      it "without errors in block_helper" do
        allow(presenter_class).to receive(:dependency_tree) do
          { block_helper: nil, context: {} }
        end

        source = <<-HBS
          {{#block_helper context}} ... {{/block_helper}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).to be_empty
      end

      it "with errors in block_helper" do
        allow(presenter_class).to receive(:dependency_tree) do
          { block_helper: {}, context: {} }
        end

        source = <<-HBS
          {{#block_helper no_a_presenter}} ... {{/block_helper}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).not_to be_empty
      end
    end

    describe "validates nested templates" do
      it "without errors" do
        allow(presenter_class).to receive(:dependency_tree) do
          { presenter: { field: nil } }
        end

        source = <<-HBS
          {{#with presenter}}
            {{field}}
          {{/with}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).to be_empty
      end

      it "with errors" do
        allow(presenter_class).to receive(:dependency_tree) do
          { presenter: { field: nil } }
        end

        source = <<-HBS
          {{#with presenter}}
            {{unallowed}}
          {{/with}}
        HBS

        errors = Curlybars.validate(presenter_class, source)

        expect(errors).not_to be_empty
      end
    end
  end
end
