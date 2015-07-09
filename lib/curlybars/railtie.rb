require 'curlybars/template_handler'

module Curlybars
  class Railtie < Rails::Railtie
    initializer 'curlybars.initialize_template_handler' do
      ActionView::Template.register_template_handler(:hbs, Curlybars::TemplateHandler)
    end
  end
end
