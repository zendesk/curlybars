require 'curlybars/lexer'
require 'curlybars/parser'
require 'curlybars/error/compile_error'

module Curlybars
  class Compiler
    def self.compile(template)
      lex = Curlybars::Lexer.lex(template.source)
      Curlybars::Parser.parse(lex).compile
    rescue RLTK::LexingError => e
      source = template.source[e.stream_offset..-1]
      message = "Invalid token: `%s` in `%s`" % [source.first, source.split("\n").first]
      raise Curlybars::Error::CompileError.new(Rails.root, message, e, template)
    rescue RLTK::NotInLanguage => e
      position = e.current.position
      source = template.source[position.stream_offset..-1]
      message = "Parsing error: `%s` in `%s`" % [source.first(position.length), source.split("\n").first]
      raise Curlybars::Error::CompileError.new(Rails.root, message, position, template)
    end
  end
end
