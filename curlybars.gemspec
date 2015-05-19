require './lib/curlybars/version'

Gem::Specification.new do |s|
  s.name        = 'curlybars'
  s.version     = Curlybars::VERSION

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

  s.metadata['allowed_push_host'] = "https://gem.zdsys.com/gems/"

  s.require_paths = %w(lib)

  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency("actionpack", [">= 3.1", "< 5.0"])
  s.add_dependency("rltk", "3.0.1")
  s.add_dependency("ffi", "1.9.6")
  s.add_dependency("curly-templates", "~> 2.0")

  s.add_development_dependency("railties", [">= 3.1", "< 5.0"])
  s.add_development_dependency("rake")
  s.add_development_dependency("rspec-rails", "~> 3.2")
  s.add_development_dependency("genspec")
  s.add_development_dependency("rubocop", "~> 0.29.1")
  s.add_development_dependency("byebug", "~> 3.5")
  s.add_development_dependency("bundler")
  s.add_development_dependency("private_gem")

  s.files       = Dir.glob('lib/**/*.rb')
  s.executables = Dir.glob('bin/**/*').map {|f| File.basename(f)}
  s.test_files  = Dir.glob('spec/**/*_spec.rb')
end
