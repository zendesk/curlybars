class Dashboards::CollectionPresenter < Curlybars::Presenter
  presents :items, :name

  def items
    @items
  end
end
