require File.expand_path('boot', __dir__)

require 'action_controller/railtie'

Bundler.require(*Rails.groups)
require "curlybars"

module Dummy
  class Application < Rails::Application
    config.cache_store = :memory_store
    config.active_support.to_time_preserves_timezone = :zone
  end
end
