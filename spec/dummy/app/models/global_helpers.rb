class GlobalHelpers
  attr_reader :context
  extend Curlybars::MethodWhitelist

  allow_methods :current_user_name, :current_account_name

  def initialize(context)
    @context = context
  end

  def current_user_name
    context.current_user.first_name
  end

  def current_account_name
    context.current_account.name
  end
end
