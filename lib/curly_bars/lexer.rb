require 'rltk/lexer'

module CurlyBars
  class Lexer < RLTK::Lexer
    rule(/{{!--/) { push_state :comment_block }
    rule(/.*?(?=--}})/m, :comment_block)
    rule(/--}}/, :comment_block) { pop_state }

    rule(/{{!/) { push_state :comment }
    rule(/.*?(?=}})/m, :comment)
    rule(/}}/, :comment) { pop_state }

    rule(/{{/) { push_state :expression; :CURLYSTART }
    rule(/}}/, :expression) { pop_state; :CURLYEND }

    rule(/#if(?=\s)/, :expression) { :IF }
    rule(/\/\s*if/, :expression) { :ENDIF }

    rule(/#unless(?=\s)/, :expression) { :UNLESS }
    rule(/\/unless/, :expression) { :UNLESSCLOSE }

    rule(/#each(?=\s)/, :expression) { :EACH }
    rule(/\/each/, :expression) { :EACHCLOSE }

    rule(/#with(?=\s)/, :expression) { :WITH }
    rule(/\/with/, :expression) { :WITHCLOSE }

    rule(/else/, :expression) { :ELSE }

    rule(/(#[A-Za-z][\w\.]*\??)/, :expression) { |helper| [:HELPER, helper] }

    rule(/[A-Za-z][\w\.]*\??/, :expression) { |name| [:PATH, name] }

    rule(/\s/, :expression)

    rule(/.*?(?={{|\z)/m) { |text| [:TEXT, text] }
  end
end
