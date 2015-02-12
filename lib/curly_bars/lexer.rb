require 'rltk/lexer'

module CurlyBars
  class Lexer < RLTK::Lexer
    rule(/{{!--/) { push_state :comment_block }
    rule(/.*?(?=--}})/m, :comment_block)
    rule(/--}}/, :comment_block) { pop_state }

    rule(/{{!/) { push_state :comment }
    rule(/.*?(?=}})/m, :comment)
    rule(/}}/, :comment) { pop_state }

    rule(/{{/) { push_state :curly; :START }
    rule(/}}/, :curly) { pop_state; :END }

    rule(/#if(?=\s)/, :curly) { :IF }
    rule(/\/\s*if/, :curly) { :ENDIF }

    rule(/#unless(?=\s)/, :curly) { :UNLESS }
    rule(/\/unless/, :curly) { :UNLESSCLOSE }

    rule(/#each(?=\s)/, :curly) { :EACH }
    rule(/\/each/, :curly) { :EACHCLOSE }

    rule(/#with(?=\s)/, :curly) { :WITH }
    rule(/\/with/, :curly) { :WITHCLOSE }

    rule(/else/, :curly) { :ELSE }

    rule(/(#[A-Za-z][\w\.]*\??)/, :curly) { |helper| [:HELPER, helper] }

    rule(/[A-Za-z][\w\.]*\??/, :curly) { |name| [:PATH, name] }

    rule(/\s/, :curly)

    rule(/.*?(?={{|\z)/m) { |text| [:TEXT, text] }
  end
end
