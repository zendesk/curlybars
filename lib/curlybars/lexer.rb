require 'rltk/lexer'

# rubocop:disable Style/RegexpLiteral, Style/Semicolon
module Curlybars
  class Lexer < RLTK::Lexer
    match_first

    # The following is an identifier Handlebars compliant
    # IDENTIFIER = '[A-Za-z_][0-9\w]*'

    # This accomodates the edge case of identifiers containing dashes
    # IDENTIFIER = '[A-Za-z_\-][0-9\w\-]*'

    # This accomodates the edge case of identifiers containing all numbers
    # and dashes
    IDENTIFIER = '[0-9A-Za-z_\-][0-9\w\-]*'.freeze

    r(/\\{/) { [:TEXT, '{'] }
    r(/\\/) { [:TEXT, '\\'] }

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

    r(/if\b/, :curly) { :IF }
    r(/unless\b/, :curly) { :UNLESS }
    r(/each\b/, :curly) { :EACH }
    r(/with\b/, :curly) { :WITH }
    r(/else\b/, :curly) { :ELSE }

    r(/true/, :curly) { [:LITERAL, true] }
    r(/false/, :curly) { [:LITERAL, false] }
    r(/[-+]?\d+/, :curly) { |integer| [:LITERAL, integer.to_i] }
    r(/'(.*?)'/, :curly) { [:LITERAL, match[1].inspect] }
    r(/"(.*?)"/, :curly) { [:LITERAL, match[1].inspect] }

    r(/@((?:\.\.\/)*#{IDENTIFIER})/, :curly) { |variable| [:VARIABLE, match[1]] }

    r(/(#{IDENTIFIER})\s*=/, :curly) { [:KEY, match[1]] }
    r(/(?:\.\.\/)*(?:#{IDENTIFIER}\.)*#{IDENTIFIER}/, :curly) { |name| [:PATH, name] }

    r(/\s/, :curly)

    r(/.*?(?=\\|{{|\z)/m) { |text| [:TEXT, text] }
  end
end
