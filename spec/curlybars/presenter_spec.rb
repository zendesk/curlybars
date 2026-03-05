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
end
