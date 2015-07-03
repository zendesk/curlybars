module CurlybarsPresenters
  class Categories::IndexPresenter < Curlybars::Presenter
    presents :categories
    allow_methods :categories

    def categories
      @categories.map { |category| Shared::CategoryPresenter.new(category) }
    end
  end
end
