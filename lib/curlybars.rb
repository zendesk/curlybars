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
  VERSION = "0.3.0"

  class << self
    # Compiles a Curlybars template to Ruby code.
    #
    # source - The source HBS String that should be compiled.
    # file_name - The the file name of the template being compiled (defaults to `nil`).
    #
    # Returns a String containing the Ruby code.
    def compile(source, file_name = nil)
      ast(source, file_name).compile
    end

    # Validates the source against a presenter.
    #
    # presenter_class - the presenter class, used to validate the source.
    # source - The source HBS String that should be validated.
    # file_name - The the file name of the template being validated (defaults to `nil`).
    #
    # Returns an array of Curlybars::Error::Validation
    def validate(presenter_class, source, file_name = nil)
      dependency_tree = presenter_class.dependency_tree
      errors = ast(source, file_name).validate(dependency_tree)
      errors.flatten!
      errors.compact!
      errors
    end

    # Check if the source is valid for a given presenter.
    #
    # presenter_class - the presenter class, used to check if the source is valid.
    # source - The source HBS String that should be check to be valid.
    # file_name - The the file name of the template being checked (defaults to `nil`).
    #
    # Returns true if the template is valid, false otherwise.
    def valid?(presenter_class, source, file_name = nil)
      errors = validate(presenter_class, source, file_name)
      errors.empty?
    end

    private

    def ast(source, file_name)
      tokens = Curlybars::Lexer.lex(source, file_name)
      Curlybars::Parser.parse(tokens)
    rescue RLTK::LexingError => lexing_error
      raise Curlybars::Error::Lex.new(source, file_name, lexing_error)
    rescue RLTK::NotInLanguage => not_in_language_error
      raise Curlybars::Error::Parse.new(source, not_in_language_error)
    end
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
require 'curlybars/error/validate'
require 'curlybars/error/render'
require 'curlybars/template_handler'
require 'curlybars/railtie' if defined?(Rails)
require 'curlybars/presenter'
require 'curlybars/method_whitelist'
