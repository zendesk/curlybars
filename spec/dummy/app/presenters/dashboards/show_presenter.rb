class Dashboards::ShowPresenter < Curlybars::Presenter
  presents :message

  allow_methods :message, :welcome

  def message
    @message
  end

  def welcome
    # This is a helper method:
    welcome_message
  end
end
