Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name              = 'curlybars'
  s.version           = '0.1.0'
  s.date              = '2015-02-13'

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
  s.add_development_dependency("rspec", "~> 2.12")
  s.add_development_dependency("genspec")

  # = MANIFEST =
  s.files = %w[
    Gemfile
    README.md
    Rakefile

  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^spec\/.*_spec\.rb/ }
end
