class Category
  attr_reader :title

  def initialize(options)
    @title = options[:title]
  end
end
