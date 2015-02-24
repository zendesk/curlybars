module CurlybarsPresenters
  class Articles::ShowPresenter < Curlybars::Presenter
    presents :article
    allow_methods :author, :user, :title

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
end
