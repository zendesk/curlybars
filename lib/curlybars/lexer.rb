# frozen_string_literal: true

require 'strscan'
require 'curlybars/token'

# rubocop:disable Style/RegexpLiteral, Style/Semicolon
module Curlybars
  class Lexer
    class Error < StandardError
      attr_reader :stream_offset, :line_number, :line_offset, :remainder

      def initialize(stream_offset, line_number, line_offset, remainder)
        @stream_offset = stream_offset
        @line_number = line_number
        @line_offset = line_offset
        @remainder = remainder
        super("Unable to match string with any of the given rules: #{remainder}")
      end
    end

    # Rules are tried in definition order and the first match wins. A rule
    # can declare the bytes its matches start with (`first:`), and is then
    # only tried when the next byte is one of them. Rules without `first:`
    # are tried at every byte.
    # Each rule belongs to a state; the current state is the top of a stack
    # that rule actions manipulate with push_state and pop_state.
    # Actions receive the matched text and can read capture groups with
    # @scanner[n].
    Rule = Data.define(:pattern, :action)

    @rules = Hash.new { |hash, state| hash[state] = [] }
    # For each state, the rules to try for each value of the next byte.
    @dispatch = Hash.new { |hash, state| hash[state] = Array.new(256) { [] } }

    class << self
      attr_reader :rules, :dispatch

      def r(pattern, state = :default, first: nil, &action)
        rule = Rule.new(pattern, action || proc {})
        @rules[state] << rule
        (first ? first.bytes : 0..255).each { |byte| @dispatch[state][byte] << rule }
      end

      def lex(string, file_name = nil)
        new(string, file_name).tokens
      end
    end

    # The following is an identifier Handlebars compliant
    # IDENTIFIER = '[A-Za-z_][0-9\w]*'

    # This accomodates the edge case of identifiers containing dashes
    # IDENTIFIER = '[A-Za-z_\-][0-9\w\-]*'

    # This accomodates the edge case of identifiers containing all numbers
    # and dashes
    IDENTIFIER = '[0-9A-Za-z_\-][0-9\w\-]*'
    IDENTIFIER_START = [*'0'..'9', *'A'..'Z', *'a'..'z', '_', '-'].join.freeze

    r(/\\{/, first: '\\') { [:TEXT, '{'] }
    r(/\\/, first: '\\') { [:TEXT, '\\'] }

    # Comments are skipped up to their closing delimiter, or to the end of
    # the template when they are not closed.
    r(/{{!--.*?(?:--}}|\z)/m, first: '{')
    r(/{{!.*?(?:}}|\z)/m, first: '{')

    # The tilde operator strips whitespace from the adjacent text:
    # `{{~` from the previous token and `~}}` from the next one.
    r(/{{~/, first: '{') { rstrip_previous_text; push_state :curly; :START }
    r(/~}}/, :curly, first: '~') { pop_state; lstrip_next_text; :END }

    r(/{{/, first: '{') { push_state :curly; :START }
    r(/}}/, :curly, first: '}') { pop_state; :END }

    r(/\(/, :curly, first: '(') { push_state :curly; :LPAREN }
    r(/\)/, :curly, first: ')') { pop_state; :RPAREN }

    r(/#/, :curly, first: '#') { :HASH }
    r(/\//, :curly, first: '/') { :SLASH }
    r(/>/, :curly, first: '>') { :GT }

    r(/if\b/, :curly, first: 'i') { :IF }
    r(/unless\b/, :curly, first: 'u') { :UNLESS }
    r(/each\b/, :curly, first: 'e') { :EACH }
    r(/with\b/, :curly, first: 'w') { :WITH }
    r(/else\b/, :curly, first: 'e') { :ELSE }

    r(/true/, :curly, first: 't') { [:LITERAL, true] }
    r(/false/, :curly, first: 'f') { [:LITERAL, false] }
    r(/[-+]?\d+/, :curly, first: '-+0123456789') { |integer| [:LITERAL, integer.to_i] }
    r(/'(.*?)'/, :curly, first: "'") { [:LITERAL, @scanner[1].inspect] }
    r(/"(.*?)"/, :curly, first: '"') { [:LITERAL, @scanner[1].inspect] }

    r(/@((?:\.\.\/)*#{IDENTIFIER})/o, :curly, first: '@') { [:VARIABLE, @scanner[1]] }

    r(/(#{IDENTIFIER})\s*=/o, :curly, first: IDENTIFIER_START) { [:KEY, @scanner[1]] }
    r(/(?:\.\.\/)*(?:#{IDENTIFIER}\.)*#{IDENTIFIER}/o, :curly, first: ".#{IDENTIFIER_START}") { |name| [:PATH, name] }

    r(/\s+/, :curly, first: " \t\n\v\f\r")

    r(/.*?(?=\\|{{|\z)/m) { |text| [:TEXT, @tokens.length == @lstrip_index ? text.lstrip : text] }

    def initialize(string, file_name)
      @string = string
      @scanner = StringScanner.new(string)
      @file_name = file_name
      @states = [:default]
      @tokens = []
      @lstrip_index = nil
    end

    def tokens
      stream_offset = 0
      line_number = 1
      line_offset = 0

      until @scanner.eos?
        text = nil
        candidates = self.class.dispatch[@states.last][@string.getbyte(@scanner.pos)]
        rule = candidates.detect { |candidate| text = @scanner.scan(candidate.pattern) }
        raise Error.new(stream_offset, line_number, line_offset, @scanner.rest) unless rule

        type, value = instance_exec(text, &rule.action)

        if type
          position = StreamPosition.new(stream_offset, line_number, line_offset, text.length, @file_name)
          @tokens << Token.new(type, value, position)
        end

        stream_offset += text.length
        newlines = text.count("\n")
        if newlines > 0
          line_number += newlines
          line_offset = text.length - text.rindex("\n") - 1
        else
          line_offset += text.length
        end
      end

      @tokens << Token::EOS
    end

    private

    def push_state(state)
      @states.push(state)
      nil
    end

    def pop_state
      @states.pop
      nil
    end

    def rstrip_previous_text
      previous = @tokens.last
      return unless previous&.type == :TEXT

      @tokens[-1] = Token.new(:TEXT, previous.value.rstrip, previous.position)
    end

    # The rule calling this emits a token at index @tokens.length, so the
    # following token lands at @tokens.length + 1.
    def lstrip_next_text
      @lstrip_index = @tokens.length + 1
    end
  end
end
# rubocop:enable Style/RegexpLiteral, Style/Semicolon
