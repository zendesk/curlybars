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

    def initialize
      @presenters_namespace = ''
    end
  end
end
