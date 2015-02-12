require 'curly_bars/template_handler'

module CurlyBars
  class Railtie < Rails::Railtie
    initializer 'curly.initialize_template_handler' do
      ActionView::Template.register_template_handler(:hbs, CurlyBars::TemplateHandler)
    end
  end
end
