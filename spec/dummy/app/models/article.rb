class Article
  attr_reader :id, :title, :comment, :body, :author

  def initialize(id: nil, title: nil, comment: nil, body: nil, author: nil)
    @id = id || 1
    @title = title || "The Prince"
    @comment = comment || "<script>alert('bad')</script>"
    @body = body || "This is <strong>important</strong>!"
    @author = author || User.new(3, "Nicolò")
  end
end
