require 'curlybars/version'

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
  class << self
    # Compiles a Curlybars template to Ruby code.
    #
    # source - The source HBS String that should be compiled.
    # identifier - The the file name of the template being compiled (defaults to `nil`).
    #
    # Returns a String containing the Ruby code.
    def compile(source, identifier = nil)
      transformers = Curlybars.configuration.compiler_transformers
      transformed_source = transformers.inject(source) do |memo, transformer|
        transformer.transform(memo, identifier)
      end

      ast(transformed_source, identifier).compile
    end

    # Validates the source against a presenter.
    #
    # presenter_class - the presenter class, used to validate the source.
    # source - The source HBS String that should be validated.
    # identifier - The the file name of the template being validated (defaults to `nil`).
    #
    # Returns an array of Curlybars::Error::Validation
    def validate(presenter_class, source, identifier = nil, **options)
      options.reverse_merge! strict: false

      unless presenter_class.respond_to?(:dependency_tree)
        raise "#{presenter_class} must implement `.dependency_tree` or extend `Curlybars::MethodWhitelist`"
      end
      errors = begin
        dependency_tree = presenter_class.dependency_tree(strict: options[:strict])

        branches = [dependency_tree]
        ast(source, identifier).validate(branches)
      rescue Curlybars::Error::Base => ast_error
        [ast_error]
      end
      errors.flatten!
      errors.compact!
      errors
    end

    # Check if the source is valid for a given presenter.
    #
    # presenter_class - the presenter class, used to check if the source is valid.
    # source - The source HBS String that should be check to be valid.
    # identifier - The the file name of the template being checked (defaults to `nil`).
    #
    # Returns true if the template is valid, false otherwise.
    def valid?(presenter_class, source, identifier = nil, **options)
      errors = validate(presenter_class, source, identifier, **options)
      errors.empty?
    end

    private

    def processors
      [Curlybars::Processor::Tilde] + Curlybars.configuration.custom_processors
    end

    def ast(source, identifier)
      tokens = Curlybars::Lexer.lex(source, identifier)

      processors.each { |processor| processor.process!(tokens, identifier) }

      Curlybars::Parser.parse(tokens)
    rescue RLTK::LexingError => lexing_error
      raise Curlybars::Error::Lex.new(source, identifier, lexing_error)
    rescue RLTK::NotInLanguage => not_in_language_error
      raise Curlybars::Error::Parse.new(source, not_in_language_error)
    end
  end
end

require 'curlybars/safe_buffer'
require 'curlybars/configuration'
require 'curlybars/rendering_support'
require 'curlybars/parser'
require 'curlybars/position'
require 'curlybars/lexer'
require 'curlybars/parser'
require 'curlybars/processor/token_factory'
require 'curlybars/processor/tilde'
require 'curlybars/error/lex'
require 'curlybars/error/parse'
require 'curlybars/error/compile'
require 'curlybars/error/validate'
require 'curlybars/error/render'
require 'curlybars/template_handler'
require 'curlybars/railtie' if defined?(Rails)
require 'curlybars/presenter'
require 'curlybars/method_whitelist'
