class User
  def initialize(first_name)
    @first_name = first_name
  end

  def first_name
    @first_name
  end

  def avatar
    OpenStruct.new(url: 'http://example.com/foo.png')
  end
end
