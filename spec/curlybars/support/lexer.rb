module UnitTest
  module Lexer
    def lex(hbs)
      Curlybars::Lexer.lex(hbs).map(&:type)
    end
  end
end
