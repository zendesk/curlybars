# frozen_string_literal: true

class ArticlesController < ApplicationController
  def show
    @article = Article.new
  end
end
