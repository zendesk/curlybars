class User
  def initialize(first_name)
    @first_name = first_name
  end

  def first_name
    @first_name
  end

  def created_at
    DateTime.iso8601('2015-02-03T13:25:06+00:00')
  end

  def avatar
    OpenStruct.new(url: 'http://example.com/foo.png')
  end
end
