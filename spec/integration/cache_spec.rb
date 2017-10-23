describe "caching" do
  class DummyCache
    attr_reader :reads, :hits

    def initialize
      @store = {}
      @reads = 0
      @hits = 0
    end

    def fetch(key)
      @reads += 1
      if @store.key?(key)
        @hits += 1
        @store[key]
      else
        value = yield
        @store[key] = value
        value
      end
    end
  end

  let(:global_helpers_providers) { [] }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context")) }
  let(:cache) { DummyCache.new }

  before do
    Curlybars.configure do |config|
      config.cache = cache.method(:fetch)
    end
  end

  after do
    Curlybars.reset
  end

  describe "{{#each}}" do
    let(:article_presenter_class) do
      Class.new(Curlybars::Presenter) do
        attr_reader :title
        presents :id, :title
        allow_methods :title

        def cache_key
          @id
        end
      end
    end

    before do
      allow(presenter).to receive(:allows_method?).with(:articles) { true }

      articles = [
        article_presenter_class.new(nil, id: 1, title: "Article 1"),
        article_presenter_class.new(nil, id: 2, title: "Article 2")
      ]

      allow(presenter).to receive(:articles) { articles }
    end

    it "invokes cache if presenter responds to #cache_key" do
      template = Curlybars.compile(<<-HBS)
        {{#each articles}}{{/each}}
      HBS

      eval(template)

      expect(cache.reads).to eq(2)
      expect(cache.hits).to eq(0)
    end

    it "reuses cached values" do
      template = Curlybars.compile(<<-HBS)
        {{#each articles}}
          a
        {{/each}}

        {{#each articles}}
          a
        {{/each}}
      HBS

      eval(template)

      expect(cache.reads).to eq(4)
      expect(cache.hits).to eq(2)
    end

    it "generates unique cache keys per template" do
      template = Curlybars.compile(<<-HBS)
        {{#each articles}}
          a
        {{/each}}

        {{#each articles}}
          b
        {{/each}}
      HBS

      eval(template)

      expect(cache.reads).to eq(4)
      expect(cache.hits).to eq(0)
    end

    it "produces correct output from cached presenters" do
      template = Curlybars.compile(<<-HBS)
        {{#each articles}}
          - {{title}}
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        - Article 1
        - Article 2
      HTML
    end
  end
end
