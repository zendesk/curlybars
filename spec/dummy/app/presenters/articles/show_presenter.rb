require 'articles/user_presenter'

class Articles::ShowPresenter < Curly::Presenter
  presents :article

  def title
    @article.title
  end

  def author
    Articles::UserPresenter.new(@article.author)
  end

  def user
    Articles::UserPresenter.new(current_user)
  end
end
