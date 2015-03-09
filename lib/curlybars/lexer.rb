require 'rltk/lexer'

module Curlybars
  class Lexer < RLTK::Lexer
    match_first

    IDENTIFIER = '[A-Za-z_]\w*'

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

    r(/if(?=\s|})/, :curly) { :IF }
    r(/unless(?=\s|})/, :curly) { :UNLESS }
    r(/each(?=\s|})/, :curly) { :EACH }
    r(/with(?=\s|})/, :curly) { :WITH }
    r(/else(?=\s|})/, :curly) { :ELSE }
    r(/(#{IDENTIFIER})\s*=/, :curly) { |key| [:KEY, match[1]] }
    r(/true/, :curly) { |string| [:BOOLEAN, true] }
    r(/false/, :curly) { |string| [:BOOLEAN, false] }
    r(/(..\/)*(#{IDENTIFIER}\.)*#{IDENTIFIER}\??/, :curly) { |name| [:PATH, name] }
    r(/\d+/, :curly) { |integer| [:INTEGER, integer.to_i] }
    r(/'(.*?)'/m, :curly) { |string| [:STRING, match[1]] }
    r(/"(.*?)"/m, :curly) { |string| [:STRING, match[1]] }

    r(/\s/, :curly)

    r(/.*?(?=\\|{{|\z)/m) { |text| [:TEXT, text] }
  end
end
