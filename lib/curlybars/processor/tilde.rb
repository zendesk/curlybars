module Curlybars
  module Processor
    class Tilde
      class << self
        def process!(tokens)
          tokens.each_with_index do |token, index|
            case token.type
            when :TILDE_START
              tokens[index] = new_token(token, type: :START)
              next if index == 0
              strip_token_if_text(tokens, index - 1, :rstrip)
            when :TILDE_END
              tokens[index] = new_token(token, type: :END)
              next if index == (tokens.length - 1)
              strip_token_if_text(tokens, index + 1, :lstrip)
            end
          end
        end

        def strip_token_if_text(tokens, index, strip_method)
          token = tokens[index]
          return if token.type != :TEXT
          stripped_value = token.value.public_send(strip_method)
          tokens[index] = new_token(token, value: stripped_value)
        end

        def new_token(old, type: nil, value: nil)
          RLTK::Token.new(
            type || old.type,
            value || old.value,
            old.position
          )
        end
      end
    end
  end
end
