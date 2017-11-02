class User
  attr_reader :first_name, :id
  def initialize(id, first_name)
    @id = id
    @first_name = first_name
  end

  def created_at
    Time.iso8601('2015-02-03T13:25:06+00:00')
  end

  def avatar
    OpenStruct.new(url: 'http://example.com/foo.png')
  end
end
