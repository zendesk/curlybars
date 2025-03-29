require File.expand_path('boot', __dir__)

require 'action_controller/railtie'

Bundler.require(*Rails.groups)
require "curlybars"

module Dummy
  class Application < Rails::Application
    config.cache_store = :memory_store
    config.active_support.to_time_preserves_timezone = :zone
    config.action_controller.escape_json_responses = false if ActionController::Base.respond_to?(:escape_json_responses)
  end
end
