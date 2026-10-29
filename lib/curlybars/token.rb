# frozen_string_literal: true

module Curlybars
  # A token produced by Curlybars::Lexer and consumed by Curlybars::Parser.
  # Custom processors receive and may replace these (see Processor::TokenFactory).
  Token = Struct.new(:type, :value, :position) do
    # Tokens are equal when type and value match, regardless of position.
    def ==(other)
      type == other.type && value == other.value
    end

    # Matches RLTK::Token#to_s, e.g. `PATH(a)`, or `END` without a value.
    def to_s
      value ? "#{type}(#{value})" : type.to_s
    end
  end

  Token::EOS = Token.new(:EOS, nil, nil).freeze

  # Where a token, or a node built from a run of tokens, appears in the source.
  StreamPosition = Struct.new(:stream_offset, :line_number, :line_offset, :length, :file_name) do
    # Kept from RLTK::StreamPosition.
    alias_method :start, :line_offset
  end

  # A shared position for tokens that have no source, e.g. in an empty template.
  StreamPosition::NULL = StreamPosition.new(0, 0, 0, 0, nil).freeze
end
