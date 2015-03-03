# Curlybars is a view system based on Curly that uses Handlebars syntax.
#
# Each view consists of two parts, a template and a presenter.
# The template is a valid Handlebars template.
#
#   {{#with invoice}}
#     Hello {{recipient.first_name}},
#     you owe us {{local_currency amount}}.
#   {{/with}}
#
# In the example above `recipient.first_name` is a path
# `local_currency amount` is an helper
#
# See Curlybars::Presenter for more information on presenters.
module Curlybars
  VERSION = "0.2.1"

  # Compiles a Curlybars template to Ruby code.
  #
  # source - The source HBS String that should be compiled.
  # file_name - The the file name of the template being compiled.
  #
  # Returns a String containing the Ruby code.
  def self.compile(source, file_name = nil)
    tokens = Curlybars::Lexer.lex(source, file_name)
    ast = Curlybars::Parser.parse(tokens)
    ast.compile
  rescue RLTK::LexingError => lexing_error
    raise Curlybars::Error::Lex.new(source, file_name, lexing_error)
  rescue RLTK::NotInLanguage => not_in_language_error
    raise Curlybars::Error::Parse.new(source, not_in_language_error)
  end

  # Whether the Curlybars template is valid.
  #
  # source - The source HBS String that should be verified.
  # file_name - The the file name of the template being verified.
  #
  # Returns true if the template is valid, false otherwise.
  def self.valid?(source, file_name)
    # TODO, or remove if doesn't make sense
  end
end

require 'curlybars/configuration'
require 'curlybars/rendering_support'
require 'curlybars/parser'
require 'curlybars/position'
require 'curlybars/lexer'
require 'curlybars/parser'
require 'curlybars/error/lex'
require 'curlybars/error/parse'
require 'curlybars/error/compile'
require 'curlybars/error/render'
require 'curlybars/template_handler'
require 'curlybars/railtie' if defined?(Rails)
require 'curlybars/presenter'
require 'curlybars/method_whitelist'
