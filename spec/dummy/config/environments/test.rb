Rails.application.configure do
  config.eager_load = false
  config.action_dispatch.show_exceptions = false
  config.active_support.deprecation = :raise
  config.secret_key_base = "yolo"
end
