require 'articles/avatar_presenter'

class Articles::UserPresenter
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def first_name
    user.first_name
  end

  def avatar
    Articles::AvatarPresenter.new(@user.avatar)
  end
end
