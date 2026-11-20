# frozen_string_literal: true

describe Curlybars::PartialCache do
  let(:cache) { Curlybars::PartialCache.new(2) }
  let(:presenter) { Curlybars::PartialPresenter.new(nil, name: "World") }

  def render(partial)
    partial.call({ start_time: nil, depth: 1 }, presenter, [], nil)
  end

  describe "#fetch" do
    it "returns a lambda that renders the partial" do
      partial = cache.fetch("partial:greeting", "Hello {{name}}")

      expect(render(partial)).to eq("Hello World")
    end

    it "returns the cached lambda for the same identifier and source" do
      first = cache.fetch("partial:greeting", "Hello {{name}}")

      expect(cache.fetch("partial:greeting", +"Hello {{name}}")).to be(first)
    end

    it "does not compile again on a cache hit" do
      cache.fetch("partial:greeting", "Hello {{name}}")
      allow(Curlybars).to receive(:compile)
      cache.fetch("partial:greeting", "Hello {{name}}")

      expect(Curlybars).not_to have_received(:compile)
    end

    it "compiles again when the source changes", :aggregate_failures do
      first = cache.fetch("partial:greeting", "Hello {{name}}")
      second = cache.fetch("partial:greeting", "Bye {{name}}")

      expect(second).not_to be(first)
      expect(render(second)).to eq("Bye World")
    end

    it "keeps entries for different identifiers apart" do
      first = cache.fetch("partial:one", "Hello {{name}}")
      second = cache.fetch("partial:two", "Hello {{name}}")

      expect(second).not_to be(first)
    end

    it "is not affected when the caller mutates the source afterwards" do
      source = +"Hello {{name}}"
      first = cache.fetch("partial:greeting", source)
      source.replace("Bye {{name}}")

      expect(cache.fetch("partial:greeting", "Hello {{name}}")).to be(first)
    end

    it "evicts the least recently used entry when full", :aggregate_failures do
      one = cache.fetch("partial:one", "1")
      two = cache.fetch("partial:two", "2")
      cache.fetch("partial:one", "1")
      cache.fetch("partial:three", "3")

      expect(cache.size).to eq(2)
      expect(cache.fetch("partial:one", "1")).to be(one)
      expect(cache.fetch("partial:two", "2")).not_to be(two)
    end

    it "does not cache partials that fail to compile", :aggregate_failures do
      expect { cache.fetch("partial:broken", "{{#if}}") }.to raise_error(Curlybars::Error::Parse)

      expect(cache.size).to eq(0)
    end

    it "does not share local variables between renders", :aggregate_failures do
      partial = cache.fetch("partial:each", "{{#each items}}{{v}}{{#if @last}}!{{/if}}{{/each}}")
      item = ->(v) { Curlybars::PartialPresenter.new(nil, v: v) }
      first = Curlybars::PartialPresenter.new(nil, items: [item.call("a"), item.call("b")])
      second = Curlybars::PartialPresenter.new(nil, items: [item.call("c")])

      expect(partial.call({ start_time: nil, depth: 1 }, first, [], nil)).to eq("ab!")
      expect(partial.call({ start_time: nil, depth: 1 }, second, [], nil)).to eq("c!")
    end
  end

  describe "#clear" do
    it "removes all entries" do
      cache.fetch("partial:greeting", "Hello {{name}}")
      cache.clear

      expect(cache.size).to eq(0)
    end
  end

  describe "Curlybars.partial_cache" do
    it "is sized by the configuration" do
      Curlybars.configuration.partial_cache_size = 5

      expect(Curlybars.partial_cache.max_size).to eq(5)
    end

    it "is replaced by Curlybars.reset" do
      cache = Curlybars.partial_cache
      Curlybars.reset

      expect(Curlybars.partial_cache).not_to be(cache)
    end
  end
end
