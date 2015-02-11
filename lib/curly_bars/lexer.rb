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

    rule(/#\s*([A-Za-z_]\w*)/, :curly) { |helper| [:HELPER, match[1]] }
    rule(/\/\s*([A-Za-z_]\w*)/, :curly) { |helper| [:HELPERCLOSE, match[1]] }

    rule(/else/, :curly) { :ELSE }

    rule(/[A-Za-z][\w\.]*\??/, :curly) { |name| [:PATH, name] }

    rule(/"/, :curly) { push_state :dq_string }
    rule(/(\\"|[^"])*/, :dq_string) { |string| [:STRING, string]}
    rule(/"/, :dq_string) { pop_state }

    rule(/'/, :curly) { push_state :sq_string }
    rule(/(\\'|[^'])*/, :sq_string) { |string| [:STRING, string]}
    rule(/'/, :sq_string) { pop_state }

    rule(/\s/, :curly)

    rule(/.*?(?={{|\z)/m) { |text| [:TEXT, text] }
  end
end
