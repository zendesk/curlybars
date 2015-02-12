Rails.application.routes.draw do
  root to: "dashboards#show"
  get "/articles/1", to: "articles#show"
  get "/collection", to: "dashboards#collection"
  get "/partials", to: "dashboards#partials"
  get "/new", to: "dashboards#new"
end
