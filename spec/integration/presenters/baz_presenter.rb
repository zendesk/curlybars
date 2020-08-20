class BazPresenter
  extend Curlybars::MethodWhitelist

  allow_methods :bat, :bar

  def bat
    "foo!"
  end

  def bar
    "bar!"
  end
end
