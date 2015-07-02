class CategoriesController < ApplicationController
  def index
    @categories = [Category.new(title: 'One'), Category.new(title: 'Two')]
  end
end
