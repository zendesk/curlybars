class Posts::ShowPresenter < Curlybars::Presenter
  include CurlybarsHelper

  presents :post

  allow_methods :user, :new_comment_form, :beautify, :form, :date, :asset

  def user
    Shared::UserPresenter.new(current_user)
  end

  def new_comment_form
    Posts::NewPostFormPresenter.new
  end

  private

  def current_user
    User.new('Libo')
  end
end
