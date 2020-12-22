describe "caching" do
  let(:dummy_cache) do
    Class.new do
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
  end

  let(:global_helpers_providers) { [] }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context")) }
  let(:cache) { dummy_cache.new }

  before do
    Curlybars.configure do |config|
      config.cache = cache.method(:fetch)
    end
  end

  after do
    Curlybars.reset
  end

  describe "{{#each}}" do
    it "invokes cache if presenter responds to #cache_key" do
      template = Curlybars.compile(<<-HBS)
        {{#each array_of_users}}{{/each}}
      HBS

      eval(template)

      expect(cache.reads).to eq(1)
      expect(cache.hits).to eq(0)
    end

    it "reuses cached values" do
      template = Curlybars.compile(<<-HBS)
        {{#each array_of_users}}
          a
        {{/each}}

        {{#each array_of_users}}
          a
        {{/each}}
      HBS

      eval(template)

      expect(cache.reads).to eq(2)
      expect(cache.hits).to eq(1)
    end

    it "generates unique cache keys per template" do
      template = Curlybars.compile(<<-HBS)
        {{#each array_of_users}}
          a
        {{/each}}

        {{#each array_of_users}}
          b
        {{/each}}
      HBS

      eval(template)

      expect(cache.reads).to eq(2)
      expect(cache.hits).to eq(0)
    end

    it "produces correct output from cached presenters" do
      template = Curlybars.compile(<<-HBS)
        {{#each array_of_users}}
          - {{first_name}}
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        - Libo
      HTML
    end

    it "works for empty templates" do
      template = Curlybars.compile(<<-HBS)
        before
        {{#each array_of_users}}{{/each}}
        {{#each array_of_users}}{{/each}}
        after
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        before
        after
      HTML
    end

    it "leaves variables and contexts in correct state after a cache hit" do
      template = Curlybars.compile(<<-HBS)
        {{#each array_of_users}}a{{/each}}
        {{#each array_of_users}}a{{/each}}
        {{context}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        a
        a
        root_context
      HTML
    end
  end
end
