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

  s.required_ruby_version = ">= 3.2"

  s.add_dependency("actionpack", ">= 7.2")
  s.add_dependency("activesupport", ">= 7.2")
  s.add_dependency("ffi")
  s.add_dependency("rltk")

  s.files = Dir.glob('lib/**/*.rb')
end
