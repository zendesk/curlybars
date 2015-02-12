class ArticlesController < ApplicationController
  def show
    @article = Article.new
  end
end
