class ApplicationController < ActionController::Base
  helper_method :current_account

  def current_account
    Account.new("Testing")
  end
end
