describe Curlybars::Presenter do
  describe ".cache_key" do
    it "includes the cache keys of all presenters in the dependency list" do
      presenter = Class.new(Curlybars::Presenter) do
        version 42
        depends_on 'foo/bum'
        depends_on 'foo/aum'
      end

      dependency = Class.new(Curlybars::Presenter) do
        version 1337
      end

      dependency2 = Class.new(Curlybars::Presenter) do
        version 1338
      end

      stub_const("Foo::BarPresenter", presenter)
      stub_const("Foo::BumPresenter", dependency)
      stub_const("Foo::AumPresenter", dependency2)

      cache_key = Foo::BarPresenter.cache_key
      expect(cache_key).to eq "Foo::BarPresenter/42/Foo::AumPresenter/1338/Foo::BumPresenter/1337"
    end

    it "falls back to the view path when a dependency has no presenter class" do
      presenter = Class.new(Curlybars::Presenter) do
        version 1
        depends_on 'foo/missing'
      end

      stub_const("Foo::BarPresenter", presenter)

      expect(Foo::BarPresenter.cache_key).to eq "Foo::BarPresenter/1/foo/missing"
    end
  end

  describe ".dependencies" do
    it "doesn't include duplicates" do
      Curlybars::Presenter.dependencies
      parent = Class.new(Curlybars::Presenter) do
        depends_on 'foo'
      end
      presenter = Class.new(parent) do
        depends_on 'bar'
        depends_on 'foo'
      end
      expect(presenter.dependencies).to eq ['bar', 'foo']
    end
  end

  describe "#initialize" do
    let(:context) { double("view context") }

    it "raises when a presented identifier is neither given nor has a default" do
      presenter_class = Class.new(Curlybars::Presenter) do
        presents :post
      end

      expect { presenter_class.new(context) }.
        to raise_error(ArgumentError, "required identifier `post` missing")
    end

    it "uses the default value when the identifier is not given" do
      presenter_class = Class.new(Curlybars::Presenter) do
        presents :post, default: "the default"
      end

      presenter = presenter_class.new(context)

      expect(presenter.instance_variable_get(:@post)).to eq("the default")
    end

    it "evaluates a default block when the identifier is not given" do
      presenter_class = Class.new(Curlybars::Presenter) do
        presents(:post) { |name| "fallback for #{name}" }
      end

      presenter = presenter_class.new(context)

      expect(presenter.instance_variable_get(:@post)).to eq("fallback for post")
    end

    it "rejects a default value and a default block at the same time" do
      expect do
        Class.new(Curlybars::Presenter) do
          presents(:post, default: "the default") { "the block" }
        end
      end.to raise_error(ArgumentError, "Cannot provide both `default:` and block")
    end
  end

  describe ".exposes_helper" do
    it "defines a method that delegates to the view context" do
      context = double("view context")
      allow(context).to receive(:truncate).and_return("truncated")

      presenter_class = Class.new(Curlybars::Presenter) do
        exposes_helper :truncate
      end

      expect(presenter_class.new(context).truncate("hello")).to eq("truncated")
    end
  end

  describe "cache defaults" do
    it "defaults cache_options to an empty hash and cache_duration to nil" do
      presenter = Curlybars::Presenter.new(double("view context"))

      aggregate_failures do
        expect(presenter.cache_options).to eq({})
        expect(presenter.cache_duration).to be_nil
      end
    end
  end
end
