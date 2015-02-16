class Shared::UserPresenter
  include Curlybars::MethodsWhitelisting
  attr_reader :user

  allow_methods :first_name, :created_at, :avatar

  def initialize(user)
    @user = user
  end

  def first_name
    user.first_name
  end

  def created_at
    user.created_at
  end

  def avatar
    avatar = @user.avatar
    Shared::AvatarPresenter.new(avatar)
  end
end
