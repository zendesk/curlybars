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
    attr_accessor :presenters_namespace
    attr_accessor :nesting_limit
    attr_accessor :traversing_limit
    attr_accessor :output_limit
    attr_accessor :rendering_timeout
    attr_accessor :custom_processors
    attr_accessor :compiler_transformers
    attr_accessor :global_helpers_provider_classes

    def initialize
      @presenters_namespace = ''
      @nesting_limit = 10
      @traversing_limit = 10
      @output_limit = 1.megabyte
      @rendering_timeout = 10.seconds
      @custom_processors = []
      @compiler_transformers = []
      @global_helpers_provider_classes = []
    end
  end
end
