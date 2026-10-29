# frozen_string_literal: true

class BazPresenter
  extend Curlybars::MethodWhitelist

  allow_methods :bat, :bar

  def bat
    "bat!"
  end

  def bar
    "bar!"
  end
end
