class User
  attr_reader :first_name, :id

  def initialize(id, first_name, locale: nil)
    @id = id
    @first_name = first_name
    @locale = locale
  end

  def created_at
    Time.iso8601('2015-02-03T13:25:06+00:00')
  end

  def avatar
    base_url = "http://example.com/foo.png"
    url = @locale.nil? ? base_url : base_url + "?locale=#{@locale}"

    Struct.new(:url).new(url)
  end

  def self.translate(user, locale)
    User.new(user.id, user.first_name, locale: locale)
  end
end
