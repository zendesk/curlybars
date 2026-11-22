# frozen_string_literal: true

module Curlybars
  # A process-local cache of compiled partials.
  #
  # `Curlybars.compile` caches the generated Ruby code as a String, but turning
  # that String into something callable means parsing it with `eval`, which is
  # the expensive part. This cache keeps the result of that `eval`: a lambda
  # taking the values a partial needs to render. The lambdas can't be stored in
  # `Curlybars.cache`, which may live outside the process (e.g. `Rails.cache`).
  #
  # Partial sources can be user-provided, so the cache holds at most
  # `max_size` entries and evicts the least recently used one.
  class PartialCache
    attr_reader :max_size

    def initialize(max_size)
      @max_size = max_size
      @entries = {}
      @mutex = Mutex.new
    end

    # Returns the cached lambda for the given identifier and source, or
    # compiles one with `Curlybars.compile` and caches it.
    def fetch(identifier, source)
      key = [identifier, source]

      cached = @mutex.synchronize do
        # Reinsert the entry, so the Hash's insertion order doubles as the
        # recency order.
        @entries[key] = @entries.delete(key) if @entries.key?(key)
      end
      return cached if cached

      # Compile outside the lock. Two threads may compile the same partial at
      # once; both results are equivalent, and the last one is kept.
      compiled = build(::Curlybars.compile(source, identifier), identifier)

      @mutex.synchronize do
        @entries[[identifier.dup.freeze, source.dup.freeze]] = compiled
        @entries.shift while @entries.size > max_size
      end

      compiled
    end

    def size
      @mutex.synchronize { @entries.size }
    end

    def clear
      @mutex.synchronize { @entries.clear }
    end

    private

    def build(compiled, identifier)
      source = <<~RUBY
        lambda do |rendering_context, presenter, global_helpers_providers, partial_provider|
          #{compiled}
        end
      RUBY

      # Evaluate in a binding without local variables, so the lambda can't
      # capture (and share between renders) any variables from the outside.
      # rubocop:disable Security/Eval -- eval is the established compilation pattern for the whole engine
      eval(source, CleanBinding.get, identifier.to_s)
      # rubocop:enable Security/Eval
    end

    module CleanBinding
      def self.get
        binding
      end
    end
    private_constant :CleanBinding
  end
end
