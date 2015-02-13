class Articles::ShowPresenter < Curly::Presenter
  presents :article

  def title
    @article.title
  end

  def author
    Shared::UserPresenter.new(@article.author)
  end

  def user
    Shared::UserPresenter.new(current_user)
  end
end
