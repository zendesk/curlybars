module ApplicationHelper
  def welcome_message
    "Welcome!"
  end

  def current_user
    User.new(1, "Admin")
  end
end
