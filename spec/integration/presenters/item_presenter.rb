module IntegrationTest
  class ItemPresenter < Curlybars::Presenter
    attr_reader :field, :placeholder

    allow_methods :field, :placeholder

    def initialize(field:, placeholder:)
      @field = field
      @placeholder = placeholder
    end
  end
end
