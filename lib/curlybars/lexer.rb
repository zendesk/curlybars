require 'rltk/lexer'

module Curlybars
  class Lexer < RLTK::Lexer
    match_first

    r(/\\\z/) { |text| [:TEXT, '\\'] }
    r(/\\{/) { |text| [:TEXT, '{'] }

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
    r(/>/, :curly) { :GT }

    r(/if(?![A-Za-z_])/, :curly) { :IF }
    r(/unless(?![A-Za-z_])/, :curly) { :UNLESS }
    r(/each(?![A-Za-z_])/, :curly) { :EACH }
    r(/with(?![A-Za-z_])/, :curly) { :WITH }
    r(/else(?![A-Za-z_])/, :curly) { :ELSE }
    r(/([A-Za-z_]\w*)\s*=/, :curly) { |key| [:KEY, match[1]] }
    r(/true/, :curly) { |string| [:BOOLEAN, true] }
    r(/false/, :curly) { |string| [:BOOLEAN, false] }
    r(/[A-Za-z_][\w\.]*\??/, :curly) { |name| [:PATH, name] }
    r(/\d+/, :curly) { |integer| [:INTEGER, integer.to_i] }
    r(/'(.*?)'/m, :curly) { |string| [:STRING, match[1]] }
    r(/"(.*?)"/m, :curly) { |string| [:STRING, match[1]] }

    r(/\s/, :curly)

    r(/.*?(?=\\|{{|\z)/m) { |text| [:TEXT, text] }
  end
end
