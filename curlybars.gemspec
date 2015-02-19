Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name              = 'curlybars'
  s.version           = '0.1.0'
  s.date              = '2015-02-17'

  s.summary     = "Create your views using Handlebars templates!"
  s.description = "A view layer for your Rails apps that separates
    structure and logic, using Handlebars templates.\n
    Strongly inspired by Curly Template gem by Daniel Schierbeck"
  s.license     = "apache2"

  s.authors  = [
    "Libo Cannici",
    "Cristian Planas",
    "Ilkka Oksanen",
    "Mauro Codella",
    "Luís Almeida"
  ]

  s.email    = 'libo@zendesk.com'
  s.homepage = 'https://github.com/zendesk/curlybars'

  s.require_paths = %w[lib]

  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency("actionpack", [">= 3.1", "< 5.0"])
  s.add_dependency("rltk", "~> 3.0.0")
  s.add_dependency("curly-templates", "~> 2.3.2")

  s.add_development_dependency("railties", [">= 3.1", "< 5.0"])
  s.add_development_dependency("rake")
  s.add_development_dependency("rspec-rails", "~> 3.2")
  s.add_development_dependency("genspec")
  s.add_development_dependency("byebug", "~> 3.5")

  # = MANIFEST =
  s.files = %w[
    CHANGELOG.md
    CONTRIBUTING.md
    Gemfile
    README.md
    Rakefile
    curlybars.gemspec
    lib/curlybars.rb
    lib/curlybars/error/incorrect_ending_error.rb
    lib/curlybars/lexer.rb
    lib/curlybars/node/block_helper.rb
    lib/curlybars/node/each.rb
    lib/curlybars/node/each_else.rb
    lib/curlybars/node/helper.rb
    lib/curlybars/node/if.rb
    lib/curlybars/node/if_else.rb
    lib/curlybars/node/item.rb
    lib/curlybars/node/option.rb
    lib/curlybars/node/partial.rb
    lib/curlybars/node/path.rb
    lib/curlybars/node/root.rb
    lib/curlybars/node/string.rb
    lib/curlybars/node/template.rb
    lib/curlybars/node/text.rb
    lib/curlybars/node/unless.rb
    lib/curlybars/node/unless_else.rb
    lib/curlybars/node/with.rb
    lib/curlybars/parser.rb
    lib/curlybars/railtie.rb
    lib/curlybars/template_handler.rb
    lib/rails/projections.json
    spec/curlybars/lexer_spec.rb
    spec/curlybars/node/block_helper_spec.rb
    spec/curlybars/node/each_else_spec.rb
    spec/curlybars/node/each_spec.rb
    spec/curlybars/node/if_else_spec.rb
    spec/curlybars/node/if_spec.rb
    spec/curlybars/node/partial_spec.rb
    spec/curlybars/node/path_spec.rb
    spec/curlybars/node/root_spec.rb
    spec/curlybars/node/text_spec.rb
    spec/curlybars/node/unless_else_spec.rb
    spec/curlybars/node/unless_spec.rb
    spec/curlybars/parser_spec.rb
    spec/dummy/.gitignore
    spec/dummy/app/controllers/application_controller.rb
    spec/dummy/app/controllers/articles_controller.rb
    spec/dummy/app/controllers/dashboards_controller.rb
    spec/dummy/app/helpers/application_helper.rb
    spec/dummy/app/helpers/curlybars_helper.rb
    spec/dummy/app/models/article.rb
    spec/dummy/app/models/user.rb
    spec/dummy/app/presenters/articles/show_presenter.rb
    spec/dummy/app/presenters/dashboards/collection_presenter.rb
    spec/dummy/app/presenters/dashboards/item_presenter.rb
    spec/dummy/app/presenters/dashboards/new_presenter.rb
    spec/dummy/app/presenters/dashboards/partials_presenter.rb
    spec/dummy/app/presenters/dashboards/show_presenter.rb
    spec/dummy/app/presenters/layouts/application_presenter.rb
    spec/dummy/app/presenters/posts/new_post_form_presenter.rb
    spec/dummy/app/presenters/posts/show_presenter.rb
    spec/dummy/app/presenters/shared/avatar_presenter.rb
    spec/dummy/app/presenters/shared/user_presenter.rb
    spec/dummy/app/views/articles/show.html.hbs
    spec/dummy/app/views/dashboards/_item.html.curly
    spec/dummy/app/views/dashboards/collection.html.curly
    spec/dummy/app/views/dashboards/new.html.curly
    spec/dummy/app/views/dashboards/partials.html.curly
    spec/dummy/app/views/dashboards/show.html.curly
    spec/dummy/app/views/layouts/application.html.curly
    spec/dummy/config.ru
    spec/dummy/config/application.rb
    spec/dummy/config/boot.rb
    spec/dummy/config/environment.rb
    spec/dummy/config/environments/test.rb
    spec/dummy/config/routes.rb
    spec/integration/application_layout_spec.rb
    spec/integration/block_helpers_spec.rb
    spec/integration/collection_blocks_spec.rb
    spec/integration/comments_spec.rb
    spec/integration/context_blocks_spec.rb
    spec/integration/helpers_spec.rb
    spec/integration/if_blocks_spec.rb
    spec/integration/partials_spec.rb
    spec/integration/path_spec.rb
    spec/integration/with_blocks_spec.rb
    spec/matchers/have_structure.rb
    spec/spec_helper.rb
    spec/template_handler_spec.rb
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^spec\/.*_spec\.rb/ }
end
