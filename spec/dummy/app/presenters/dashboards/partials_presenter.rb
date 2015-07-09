class Dashboards::PartialsPresenter < Curlybars::Presenter
  def items
    render partial: 'item', collection: ["One", "Two"], locals: { name: "yo" }
  end
end
