class Shared::ArticlePresenter
  extend Curlybars::MethodWhitelist
  attr_reader :article

  allow_methods :title, :comment, :body, :author

  def initialize(article)
    @article = article
  end

  def title
    article.title
  end

  def comment
    article.comment
  end

  def body
    article.body.html_safe
  end

  def author
    Shared::UserPresenter.new(article.author)
  end

  def cache_key
    article.id
  end
end
