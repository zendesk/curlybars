class Posts::NewPostFormPresenter
  extend Curlybars::MethodWhitelist
  include CurlybarsHelper

  allow_methods :button_label, :title, :body, :asset, :input

  def button_label
    "submit"
  end

  def resource_name
    "community_post"
  end

  def title
    Shared::FormFieldPresenter.new(
      name: 'title',
      resource_name: resource_name,
      label: 'The title of the post',
      value: 'some value persisted in the DB'
    )
  end

  def body
    Shared::FormFieldPresenter.new(
      name: 'body',
      resource_name: resource_name,
      label: 'The body of the post',
      value: 'some other value persisted in the DB'
    )
  end
end
