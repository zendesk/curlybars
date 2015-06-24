class Article
  def title
    "The Prince"
  end

  def comment
    "<script>alert('bad')</script>"
  end

  def body
    "This is <strong>important</strong>!"
  end

  def author
    User.new("Nicolò")
  end
end
