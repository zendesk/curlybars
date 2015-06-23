class Layouts::ApplicationPresenter < Curlybars::Presenter
  allow_methods :title, :content

  def title
    "Dummy app"
  end

  def content
    yield
  end
end
