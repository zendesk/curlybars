class Shared::CategoryPresenter
  extend Curlybars::MethodWhitelist

  attr_reader :category

  allow_methods :title

  def initialize(category)
    @category = category
  end

  def title
    @category.title
  end
end
