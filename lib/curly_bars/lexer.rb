require 'rltk/lexer'

module CurlyBars
  class Lexer < RLTK::Lexer
    match_first

    r(/{{!--/) { push_state :comment_block }
    r(/--}}/, :comment_block) { pop_state }
    r(/./m, :comment_block)

    r(/{{!/) { push_state :comment }
    r(/}}/, :comment) { pop_state }
    r(/./m, :comment)

    r(/{{/) { push_state :curly; :START }
    r(/}}/, :curly) { pop_state; :END }

    r(/#\s*if(?=\s)/, :curly) { :IF }
    r(/\/\s*if/, :curly) { :ENDIF }

    r(/#\s*unless(?=\s)/, :curly) { :UNLESS }
    r(/\/unless/, :curly) { :UNLESSCLOSE }

    r(/#\s*each(?=\s)/, :curly) { :EACH }
    r(/\/each/, :curly) { :EACHCLOSE }

    r(/#\s*with(?=\s)/, :curly) { :WITH }
    r(/\/with/, :curly) { :WITHCLOSE }

    r(/#\s*([A-Za-z_]\w*)/, :curly) { |helper| set_flag(:helper); [:HELPER, match[1]] }
    r(/\/\s*([A-Za-z_]\w*)/, :curly) { |helper| unset_flag(:helper); [:HELPERCLOSE, match[1]] }

    r(/([A-Za-z_]\w*)\s*=/, :curly, [:helper]) { |key| [:KEY, match[1]] }

    r(/else/, :curly) { :ELSE }

    r(/[A-Za-z][\w\.]*\??/, :curly) { |name| [:PATH, name] }

    r(/"/, :curly) { push_state :dq_string }
    r(/"/, :dq_string) { pop_state }
    r(/(\\"|[^"])*/, :dq_string) { |string| [:STRING, string]}

    r(/'/, :curly) { push_state :sq_string }
    r(/'/, :sq_string) { pop_state }
    r(/(\\'|[^'])*/, :sq_string) { |string| [:STRING, string]}

    r(/\s/, :curly)

    r(/.*?(?={{|\z)/m) { |text| [:TEXT, text] }
  end
end
