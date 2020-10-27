module IntegrationTest
  class LetterPresenter < Curlybars::Presenter
    attr_reader :alphabet

    allow_methods :a, :b, :c, :d, :e

    def initialize(alphabet)
      @alphabet = alphabet
    end

    %i[a b c d e].each do |m|
      define_method(m) do
        present(m)
      end
    end

    private

    def present(letter)
      alphabet[letter].is_a?(Hash) ? LetterPresenter.new(alphabet[letter]) : alphabet[letter]
    end
  end
end
