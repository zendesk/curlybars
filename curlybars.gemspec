require './lib/curlybars/version'

Gem::Specification.new do |s|
  s.name        = 'curlybars'
  s.version     = Curlybars::VERSION

  s.summary     = "Create your views using Handlebars templates!"
  s.description = "A view layer for your Rails apps that separates
    structure and logic, using Handlebars templates.\n
    Strongly inspired by Curly Template gem by Daniel Schierbeck"
  s.license     = "Apache-2.0"

  s.authors = [
    "Libo Cannici",
    "Cristian Planas",
    "Ilkka Oksanen",
    "Mauro Codella",
    "Luís Almeida",
    "Andreas Garnæs"
  ]

  s.email    = 'libo@zendesk.com'
  s.homepage = 'https://github.com/zendesk/curlybars'

  s.require_paths = %w[lib]

  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency("actionpack", [">= 4.2", "< 5.2"])
  s.add_dependency("ffi")
  s.add_dependency("rltk")

  s.add_development_dependency("bundler")
  s.add_development_dependency("byebug", "~> 3.5")
  s.add_development_dependency("genspec")
  s.add_development_dependency("private_gem")
  s.add_development_dependency("railties", [">= 4.2", "< 5.2"])
  s.add_development_dependency("rake")
  s.add_development_dependency("rspec-rails", "~> 3.5")
  s.add_development_dependency("rubocop", "~> 0.51.0")
  s.add_development_dependency("rubocop-rspec", "~> 1.19.0")
  s.add_development_dependency("wwtd", ">= 0.5.3")

  s.files       = Dir.glob('lib/**/*.rb')
  s.executables = Dir.glob('bin/**/*').map { |f| File.basename(f) }
  s.test_files  = Dir.glob('spec/**/*_spec.rb')
end
