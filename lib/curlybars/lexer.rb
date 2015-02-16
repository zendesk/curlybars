require 'rltk/lexer'

module Curlybars
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

    r(/#/, :curly) { :HASH }
    r(/\//, :curly) { :SLASH }

    r(/if(?![A-Za-z_])/, :curly) { :IF }
    r(/unless(?![A-Za-z_])/, :curly) { :UNLESS }
    r(/each(?![A-Za-z_])/, :curly) { :EACH }
    r(/with(?![A-Za-z_])/, :curly) { :WITH }
    r(/else(?![A-Za-z_])/, :curly) { :ELSE }
    r(/([A-Za-z_]\w*)\s*=/, :curly) { |key| [:KEY, match[1]] }
    r(/[A-Za-z_][\w\.]*\??/, :curly) { |name| [:PATH, name] }

    r(/"/, :curly) { push_state :double_quote_string }
    r(/"/, :double_quote_string) { pop_state }
    r(/(\\"|[^"])*/, :double_quote_string) { |string| [:STRING, string]}

    r(/'/, :curly) { push_state :single_quote_string }
    r(/'/, :single_quote_string) { pop_state }
    r(/(\\'|[^'])*/, :single_quote_string) { |string| [:STRING, string]}

    r(/\s/, :curly)

    r(/.*?(?={{|\z)/m) { |text| [:TEXT, text] }
  end
end
