require 'digest'
require 'active_support/cache'
require 'active_support/core_ext/object/json'
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
      cache_key = ["Curlybars.compile", identifier, Digest::SHA256.hexdigest(source)]

      cache.fetch(cache_key) do
        ast(transformed_source(source), identifier, run_processors: true).compile
      end
    end

    # Validates the source against a presenter.
    #
    # dependency_tree - a presenter dependency tree as defined in Curlybars::MethodWhitelist
    # source - The source HBS String that should be validated.
    # identifier - The the file name of the template being validated (defaults to `nil`).
    #
    # Returns an array of Curlybars::Error::Validation
    def validate(dependency_tree, source, identifier = nil, **options)
      options.reverse_merge!(
        run_processors: true
      )

      errors = begin
        branches = [dependency_tree]
        ast(source, identifier, run_processors: options[:run_processors]).validate(branches)
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
    def valid?(presenter_class, source, identifier = nil, **)
      errors = validate(presenter_class, source, identifier, **)
      errors.empty?
    end

    # Visit nodes in the AST.
    #
    # visitor - An instance of a subclass of `Curlybars::Visitor`.
    # source - The source HBS String used to generate an AST.
    # identifier - The the file name of the template being checked (defaults to `nil`).
    def visit(visitor, source, identifier = nil)
      tree = ast(transformed_source(source), identifier, run_processors: true)
      visitor.accept(tree)
    end

    # Find all path nodes in the AST that resolve to a given path.
    # Takes into account contextual scope from block helpers like #with, #each, etc.
    #
    # target_path - The path String to search for (e.g., "user.name" or "user.organizations.id").
    # source - The source HBS String used to generate an AST.
    # identifier - The the file name of the template being checked (defaults to `nil`).
    # role - Optional Symbol or Array of Symbols to filter by syntactic role:
    #          :output     - bare output value         {{title}}
    #          :helper     - helper name               {{truncate …}}, {{#block …}}
    #          :argument   - positional argument        {{truncate title}}, (math score)
    #          :option     - keyword option value       key=title
    #          :condition  - #if / #unless expression   {{#if visible}}
    #          :collection - #each collection path      {{#each posts}}
    #          :scope      - #with scope path           {{#with author}}
    #          :partial    - partial name               {{> header}}
    #        When nil (default), all roles match (backward compatible).
    #
    # Returns an Array of Curlybars::Node::Path instances that match the target path.
    def find(target_path, source, identifier = nil, role: nil)
      tree = ast(transformed_source(source), identifier, run_processors: true)
      finder = Curlybars::PathFinder.new(tree)
      finder.find(target_path, role: role)
    end

    def global_helpers_dependency_tree
      @global_helpers_dependency_tree ||= begin
        classes = Curlybars.configuration.global_helpers_provider_classes
        classes.map(&:dependency_tree).inject({}, :merge)
      end
    end

    def cache
      @cache ||= ActiveSupport::Cache::MemoryStore.new
    end

    attr_writer :cache

    private

    def transformed_source(source)
      transformers = Curlybars.configuration.compiler_transformers
      transformers.inject(source) do |memo, transformer|
        transformer.transform(memo, identifier)
      end
    end

    def ast(source, identifier, run_processors:)
      tokens = Curlybars::Lexer.lex(source, identifier)

      Curlybars::Processor::Tilde.process!(tokens, identifier)

      if run_processors
        Curlybars.configuration.custom_processors.each do |processor|
          processor.process!(tokens, identifier)
        end
      end

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
require 'curlybars/generic'
require 'curlybars/lexer'
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
require 'curlybars/visitor'
require 'curlybars/path_finder'
