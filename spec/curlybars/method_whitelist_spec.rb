describe Curlybars::MethodWhitelist do
  let(:dummy_class) { Class.new { extend Curlybars::MethodWhitelist } }

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
  end

  describe ".dependency_tree" do
    before do
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
    end

    it "returns a dependencies tree" do
      expect(dummy_class.dependency_tree).
        to eq(
          links: [{ url: nil }],
          article: { title: nil, body: nil }
        )
    end
  end
end
