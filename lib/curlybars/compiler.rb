require 'curlybars/position'
require 'curlybars/lexer'
require 'curlybars/parser'
require 'curlybars/error/lex'
require 'curlybars/error/parse'
require 'curlybars/error/compile'
require 'curlybars/error/render'

module Curlybars
  class Compiler
    def self.compile(source, file_name)
      tokens = Curlybars::Lexer.lex(source, file_name)
      ast = Curlybars::Parser.parse(tokens)
      ast.compile
    rescue RLTK::LexingError => lexing_error
      raise Curlybars::Error::Lex.new(source, file_name, lexing_error)
    rescue RLTK::NotInLanguage => not_in_language_error
      raise Curlybars::Error::Parse.new(source, not_in_language_error)
    end
  end
end
