class Dashboards::ItemPresenter < Curlybars::Presenter
  presents :item, :name

  def item
    @item
  end

  def name
    @name
  end

  def subitems
    %w[1 2 3]
  end

  class SubitemPresenter < Curlybars::Presenter
    presents :item, :subitem

    def name
      @subitem
    end
  end
end
