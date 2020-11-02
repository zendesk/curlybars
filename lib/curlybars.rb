require 'digest'
require 'active_support/cache'
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
        ast_res = ast(source, identifier, run_processors: options[:run_processors])
        generic_helper_nodes = find_generic_helper_nodes(source, dependency_tree)
        inferred_subtree = generic_helper_nodes.entries.map do |path, node|
          [path, dependency_tree[node.arguments.first.path.to_sym]]
        end.to_h
        dependency_tree.update(inferred_subtree)
        branches = [dependency_tree]
        ast_res.validate(branches)
      rescue Curlybars::Error::Base => ast_error
        [ast_error]
      end
      errors.flatten!
      errors.compact!
      errors
    end

    def find_generic_helper_nodes(source, dependency_tree)
      generic_helper_visitor = Curlybars::Visitors::GenericHelperVisitor.new(dependency_tree)
      Curlybars.visit(generic_helper_visitor, source)
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

    # Visit nodes in the AST.
    #
    # visitor - An instance of a subclass of `Curlybars::Visitor`.
    # source - The source HBS String used to generate an AST.
    # identifier - The the file name of the template being checked (defaults to `nil`).
    def visit(visitor, source, identifier = nil)
      tree = ast(transformed_source(source), identifier, run_processors: true)
      visitor.accept(tree)
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
require 'curlybars/visitors/generic_helper_visitor'
