require 'rltk/lexer'

module CurlyBars
  class Lexer < RLTK::Lexer
    rule /{{/, :default do
      push_state :expression
      :CURLYSTART
    end

    rule /}}/, :expression do
      pop_state
      :CURLYEND
    end

    rule(/#if(?=\s)/, :expression) { :IF }
    rule(/\/\s*if/, :expression) { :ENDIF }

    rule(/\s/, :expression)

    rule /(#[A-Za-z][\w\.]*\??)/, :expression do |name|
      :HELPER
    end

    rule /#unless\s+/, :expression do
      :UNLESS
    end

    rule /\/unless/, :expression do
      :UNLESSCLOSE
    end

    rule /#each\s+/, :expression do
      :EACH
    end

    rule /\/each/, :expression do
      :EACHCLOSE
    end

    rule /#with\s+/, :expression do
      :WITH
    end

    rule /\/with/, :expression do
      :WITHCLOSE
    end

    rule /else/, :expression do
      :ELSE
    end

    rule /([A-Za-z][\w\.]*\??)/, :expression do |name|
      [ :IDENT, name ]
    end

    rule /\!/, :expression do
      push_state :comment
      :BANG
    end

    rule /([^}}]*)/, :comment do |comment|
      pop_state
      [ :COMMENT, comment ]
    end

    rule /.*?(?={{|\z)/m, :default do |output|
      [ :OUT, output ]
    end

    class << self
      alias :scan :lex
    end
  end
end
