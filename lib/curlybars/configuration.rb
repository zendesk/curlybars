module Curlybars
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reset
    @configuration = Configuration.new
  end

  class Configuration
    attr_accessor :presenters_namespace, :nesting_limit, :traversing_limit, :output_limit, :rendering_timeout, :custom_processors, :compiler_transformers, :global_helpers_provider_classes, :cache, :partial_nesting_limit, :partial_provider_class

    def initialize
      @presenters_namespace = ''
      @nesting_limit = 10
      @traversing_limit = 10
      @output_limit = 1.megabyte
      @rendering_timeout = 10.seconds
      @custom_processors = []
      @compiler_transformers = []
      @global_helpers_provider_classes = []
      @cache = ->(key, &block) { block.call }
      @partial_nesting_limit = 3
      @partial_provider_class = nil
    end
  end
end
