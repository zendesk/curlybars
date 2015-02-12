class Articles::AvatarPresenter
  attr_reader :avatar

  def initialize(avatar)
    @avatar = avatar
  end

  def url
    @avatar.url
  end
end
