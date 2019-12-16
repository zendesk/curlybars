describe Curlybars::MethodWhitelist do
  let(:dummy_class) do
    Class.new do
      extend Curlybars::MethodWhitelist

      # A method available in the context
      def foo?
        true
      end

      def qux?
        false
      end
    end
  end

  let(:validation_context_class) do
    Class.new do
      def foo?
        true
      end

      def qux?
        false
      end
    end
  end

  describe "#allowed_methods" do
    it "returns an empty array as default" do
      expect(dummy_class.new.allowed_methods).to eq([])
    end
  end

  describe ".allow_methods" do
    before do
      link_presenter = Class.new
      article_presenter = Class.new

      dummy_class.class_eval do
        allow_methods :cook, link: link_presenter, article: article_presenter
      end
    end

    it "sets the allowed methods" do
      expect(dummy_class.new.allowed_methods).to eq([:cook, :link, :article])
    end

    it "supports adding more methods for validation" do
      dummy_class.class_eval do
        allow_methods do |context, allow_method|
          if context.foo?
            allow_method.call(:bar)
          end

          if context.qux?
            allow_method.call(:quux)
          end
        end
      end

      aggregate_failures "test both allowed_methods and allows_method?" do
        expect(dummy_class.new.allowed_methods).to eq([:bar])
        expect(dummy_class.new.allows_method?(:bar)).to eq(true)
      end
    end

    it "raises when collection is not of presenters" do
      expect do
        dummy_class.class_eval { allow_methods :cook, links: ["foobar"] }
      end.to raise_error(RuntimeError)
    end

    it "raises when collection cardinality is greater than one" do
      stub_const("OnePresenter", Class.new { extend Curlybars::MethodWhitelist })
      stub_const("OtherPresenter", Class.new { extend Curlybars::MethodWhitelist })

      expect do
        dummy_class.class_eval { allow_methods :cook, links: [OnePresenter, OtherPresenter] }
      end.to raise_error(RuntimeError)
    end
  end

  describe "inheritance and composition" do
    let(:base_presenter) do
      stub_const("LinkPresenter", Class.new)

      Class.new do
        extend Curlybars::MethodWhitelist
        allow_methods :cook, link: LinkPresenter
      end
    end

    let(:helpers) do
      Module.new do
        extend Curlybars::MethodWhitelist
        allow_methods :form
      end
    end

    let(:post_presenter) do
      Class.new(base_presenter) do
        extend Curlybars::MethodWhitelist
        include Helpers
        allow_methods :wave
      end
    end

    before do
      stub_const("Helpers", helpers)
    end

    it "allows methods from inheritance and composition" do
      expect(post_presenter.new.allowed_methods).to eq([:cook, :link, :form, :wave])
    end

    it "returns a dependency_tree with inheritance and composition" do
      expect(post_presenter.dependency_tree).
        to eq(
          cook: nil,
          link: LinkPresenter,
          form: nil,
          wave: nil
        )
    end

    context "with context dependent methods" do
      let(:base_presenter) do
        stub_const("LinkPresenter", Class.new)

        Class.new do
          extend Curlybars::MethodWhitelist
          allow_methods :cook, link: LinkPresenter do |context, allow_method|
            if context.foo?
              allow_method.call(:bar)
            end
          end

          def foo?
            true
          end
        end
      end

      let(:helpers) do
        Module.new do
          extend Curlybars::MethodWhitelist
          allow_methods :form do |context, allow_method|
            if context.foo?
              allow_method.call(foo_bar: :helper)
            end
          end

          def foo?
            true
          end
        end
      end

      let(:post_presenter) do
        Class.new(base_presenter) do
          extend Curlybars::MethodWhitelist
          include Helpers
          allow_methods :wave
        end
      end

      before do
        stub_const("Helpers", helpers)
      end

      it "allows context methods from inheritance and composition" do
        expect(post_presenter.new.allowed_methods).to eq([:cook, :link, :bar, :form, :foo_bar, :wave])
      end

      it "returns a dependency_tree with inheritance and composition with context" do
        expect(post_presenter.dependency_tree(validation_context_class.new)).
          to eq(
            cook: nil,
            link: LinkPresenter,
            form: nil,
            wave: nil,
            bar: nil,
            foo_bar: :helper
          )
      end
    end
  end

  describe ".methods_schema" do
    it "setups a schema propagating nil" do
      stub_const("LinkPresenter", Class.new { extend Curlybars::MethodWhitelist })
      dummy_class.class_eval { allow_methods :cook }

      expect(dummy_class.methods_schema).to eq(cook: nil)
    end

    it "setups a schema any random type" do
      stub_const("LinkPresenter", Class.new { extend Curlybars::MethodWhitelist })
      dummy_class.class_eval { allow_methods something: :foobar }

      expect(dummy_class.methods_schema).to eq(something: :foobar)
    end

    it "setups a schema propagating the return type of the method" do
      stub_const("ArticlePresenter", Class.new { extend Curlybars::MethodWhitelist })
      dummy_class.class_eval { allow_methods article: ArticlePresenter }

      expect(dummy_class.methods_schema).to eq(article: ArticlePresenter)
    end

    it "setups a schema propagating a collection" do
      stub_const("LinkPresenter", Class.new { extend Curlybars::MethodWhitelist })
      dummy_class.class_eval { allow_methods links: [LinkPresenter] }

      expect(dummy_class.methods_schema).to eq(links: [LinkPresenter])
    end

    it "supports procs with context in schema" do
      dummy_class.class_eval { allow_methods settings: ->(context) { context.foo? ? Hash[:background_color, nil] : nil } }

      expect(dummy_class.methods_schema(validation_context_class.new)).to eq(settings: { background_color: nil })
    end

    it "supports context methods" do
      dummy_class.class_eval do
        allow_methods do |context, allow_method|
          if context.foo?
            allow_method.call(:bar)
          end
        end
      end

      expect(dummy_class.methods_schema(validation_context_class.new)).to eq(bar: nil)
    end
  end

  describe ".dependency_tree" do
    it "returns a dependencies tree" do
      link_presenter = Class.new do
        extend Curlybars::MethodWhitelist
        allow_methods :url
      end

      article_presenter = Class.new do
        extend Curlybars::MethodWhitelist
        allow_methods :title, :body
      end

      stub_const("ArticlePresenter", article_presenter)
      stub_const("LinkPresenter", link_presenter)

      dummy_class.class_eval do
        allow_methods links: [LinkPresenter], article: ArticlePresenter
      end

      expect(dummy_class.dependency_tree).
        to eq(
          links: [{ url: nil }],
          article: {
            title: nil,
            body: nil
          }
        )
    end

    it "propagates arguments" do
      dummy_class.class_eval do
        allow_methods label: ->(label) { Hash[label, nil] }
      end

      expect(dummy_class.dependency_tree(:some_label)).
        to eq(
          label: {
            some_label: nil
          }
        )
    end
  end
end
