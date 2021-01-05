describe "Collection blocks", type: :request do
  before do
    Curlybars.configure do |config|
      config.presenters_namespace = 'curlybars_presenters'
      config.global_helpers_provider_classes = [GlobalHelpers]
    end
  end

  example "Render a global helper" do
    get '/welcome'

    expect(body).to eq(<<~HTML)
      <html>
      <head>
        <title>Dummy app</title>
      </head>
      <body>
      Login as: Admin
      Account: Testing

      </body>
      </html>
    HTML
  end
end
