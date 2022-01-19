require './lib/curlybars/version'

Gem::Specification.new do |s|
  s.name        = 'curlybars'
  s.version     = Curlybars::VERSION

  s.summary     = "Create your views using Handlebars templates!"
  s.description = "A view layer for your Rails apps that separates " \
    "structure and logic, using Handlebars templates.\n" \
    "Strongly inspired by Curly Template gem by Daniel Schierbeck."
  s.license     = "Apache-2.0"

  s.authors = [
    "Libo Cannici",
    "Cristian Planas",
    "Ilkka Oksanen",
    "Mauro Codella",
    "Luís Almeida",
    "Andreas Garnæs",
    "Augusto Silva",
    "Attila Večerek"
  ]

  s.email    = 'vikings@zendesk.com'
  s.homepage = 'https://github.com/zendesk/curlybars'

  s.require_paths = %w[lib]

  s.rdoc_options = ["--charset=UTF-8"]

  s.required_ruby_version = ">= 2.4"

  s.add_dependency("actionpack", [">= 4.2", "< 7.1"])
  s.add_dependency("activesupport", [">= 4.2", "< 7.1"])
  s.add_dependency("ffi")
  s.add_dependency("rltk")

  s.add_development_dependency("bundler")
  s.add_development_dependency("byebug")
  s.add_development_dependency("railties", [">= 4.2", "< 7.1"])
  s.add_development_dependency("rake")
  s.add_development_dependency("rspec-rails", "~> 3.8")
  s.add_development_dependency("rubocop", "~> 1.6.0")
  s.add_development_dependency("rubocop-performance", "~> 1.9.0")
  s.add_development_dependency("rubocop-rake", "~> 0.5.0")
  s.add_development_dependency("rubocop-rspec", "~> 2.1.0")

  s.files       = Dir.glob('lib/**/*.rb')
end
