module IntegrationTest
  module Compile
    def compile(hbs)
      tokens = Curlybars::Lexer.lex(hbs)
      ast = Curlybars::Parser.parse(tokens)
      ast.compile
    end
  end
end
