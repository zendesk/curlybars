require 'curlybars/template_handler'
require 'curlybars/dependency_tracker'

module Curlybars
  class Railtie < Rails::Railtie
    initializer 'curlybars.initialize_template_handler' do
      ActionView::Template.register_template_handler(:hbs, Curlybars::TemplateHandler)
    end

    if defined?(CacheDigests::DependencyTracker)
      CacheDigests::DependencyTracker.register_tracker :hbs, Curlybars::DependencyTracker
    end

    if defined?(ActionView::DependencyTracker)
      ActionView::DependencyTracker.register_tracker :hbs, Curlybars::DependencyTracker
    end
  end
end
