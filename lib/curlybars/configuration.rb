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
    attr_accessor :presenters_namespace, :nesting_limit, :traversing_limit, :output_limit, :rendering_timeout, :custom_processors, :compiler_transformers, :global_helpers_provider_classes, :cache

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
    end
  end
end
