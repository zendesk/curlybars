module Curlybars
  module Processor
    class Tilde
      extend TokenFactory

      class << self
        def process!(tokens)
          tokens.each_with_index do |token, index|
            case token.type
            when :TILDE_START
              tokens[index] = create_token(:START, token.value, token.position)
              next if index == 0
              strip_token_if_text(tokens, index - 1, :rstrip)
            when :TILDE_END
              tokens[index] = create_token(:END, token.value, token.position)
              next if index == (tokens.length - 1)
              strip_token_if_text(tokens, index + 1, :lstrip)
            end
          end
        end

        def strip_token_if_text(tokens, index, strip_method)
          token = tokens[index]
          return if token.type != :TEXT
          stripped_value = token.value.public_send(strip_method)
          tokens[index] = create_token(token.type, stripped_value, token.position)
        end
      end
    end
  end
end
