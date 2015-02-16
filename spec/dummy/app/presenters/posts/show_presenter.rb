class Posts::ShowPresenter
  include CurlybarsHelper

  def initialize
    @current_user = User.new('Libo')
  end

  def user
    Shared::UserPresenter.new(@current_user)
  end

  def new_comment_form
    Posts::NewPostFormPresenter.new
  end
end
