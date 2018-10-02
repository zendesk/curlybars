require 'curlybars/template_handler'
require 'curlybars/dependency_tracker'
require 'action_view/dependency_tracker'

module Curlybars
  class Railtie < Rails::Railtie
    initializer 'curlybars.initialize_template_handler' do
      ActionView::Template.register_template_handler(:hbs, Curlybars::TemplateHandler)
      ActionView::DependencyTracker.register_tracker(:hbs, Curlybars::DependencyTracker)
    end

    initializer 'curlybars.set_cache' do
      Curlybars.cache = Rails.cache
    end
  end
end
