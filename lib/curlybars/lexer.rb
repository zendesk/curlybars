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

    r(/{{~/) { push_state :curly; :TILDE_START }
    r(/~}}/, :curly) { pop_state; :TILDE_END }

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

    r(/true/, :curly) { |boolean| [:LITERAL, true] }
    r(/false/, :curly) { |boolean| [:LITERAL, false] }
    r(/\d+/, :curly) { |integer| [:LITERAL, integer.to_i] }
    r(/'(.*?)'/m, :curly) { |string| [:LITERAL, match[1].inspect] }
    r(/"(.*?)"/m, :curly) { |string| [:LITERAL, match[1].inspect] }

    r(/@((..\/)*#{IDENTIFIER})/, :curly) { |variable| [:VARIABLE, match[1]] }

    r(/(#{IDENTIFIER})\s*=/, :curly) { |key| [:KEY, match[1]] }
    r(/(..\/)*(#{IDENTIFIER}\.)*#{IDENTIFIER}/, :curly) { |name| [:PATH, name] }

    r(/\s/, :curly)

    r(/.*?(?=\\|{{|\z)/m) { |text| [:TEXT, text] }
  end
end
