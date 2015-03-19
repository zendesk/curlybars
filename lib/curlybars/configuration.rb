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

    def initialize
      @presenters_namespace = ''
      @nesting_limit = 10
      @traversing_limit = 10
    end
  end
end
