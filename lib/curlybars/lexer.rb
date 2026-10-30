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
        @match = nil
        super("Unable to match string with any of the given rules: #{remainder}")
      end
    end

    # Rules are tried in definition order and the first match wins.
    # Each rule belongs to a state; the current state is the top of a stack
    # that rule actions manipulate with push_state and pop_state.
    # Actions receive the matched text and can read capture groups with
    # @scanner[n].
    Rule = Data.define(:pattern, :action)

    @rules = Hash.new { |hash, state| hash[state] = [] }

    class << self
      attr_reader :rules

      def r(pattern, state = :default, &action)
        @rules[state] << Rule.new(pattern, action || proc {})
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
    IDENTIFIER = '[0-9A-Za-z_\-][0-9\w\-]*'.freeze

    r(/\\{/) { [:TEXT, '{'] }
    r(/\\/) { [:TEXT, '\\'] }

    r(/{{!--/) { push_state :comment_block }
    r(/--}}/, :comment_block) { pop_state }
    r(/./m, :comment_block)

    r(/{{!/) { push_state :comment }
    r(/}}/, :comment) { pop_state }
    r(/./m, :comment)

    # The tilde operator strips whitespace from the adjacent text:
    # `{{~` from the previous token and `~}}` from the next one.
    r(/{{~/) { rstrip_previous_text; push_state :curly; :START }
    r(/~}}/, :curly) { pop_state; lstrip_next_text; :END }

    r(/{{/) { push_state :curly; :START }
    r(/}}/, :curly) { pop_state; :END }

    r(/\(/, :curly) { push_state :curly; :LPAREN }
    r(/\)/, :curly) { pop_state; :RPAREN }

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

    r(/@((?:\.\.\/)*#{IDENTIFIER})/o, :curly) { |variable| [:VARIABLE, match[1]] }

    r(/(#{IDENTIFIER})\s*=/o, :curly) { [:KEY, match[1]] }
    r(/(?:\.\.\/)*(?:#{IDENTIFIER}\.)*#{IDENTIFIER}/o, :curly) { |name| [:PATH, name] }

    r(/\s/, :curly)

    r(/.*?(?=\\|{{|\z)/m) { |text| [:TEXT, @tokens.length == @lstrip_index ? text.lstrip : text] }

    def initialize(string, file_name)
      @scanner = StringScanner.new(string)
      @file_name = file_name
      @states = [:default]
      @tokens = []
      @lstrip_index = nil
    end

    attr_reader :match

    def tokens
      stream_offset = 0
      line_number = 1
      line_offset = 0

      until @scanner.eos?
        text = nil
        rule = self.class.rules[@states.last].detect { |candidate| text = @scanner.scan(candidate.pattern) }
        raise Error.new(stream_offset, line_number, line_offset, @scanner.rest) unless rule

        @match = text.match(rule.pattern)
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
