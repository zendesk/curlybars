describe "Collection blocks", type: :request do
  before do
    Curlybars.configure do |config|
      config.presenters_namespace = 'curlybars_presenters'
    end
  end

  example "Rendering collections" do
    get '/categories'

    expect(body).to eq(<<-HTML.strip_heredoc)
      <html>
      <head>
        <title>Dummy app</title>
      </head>
      <body>

      <h1>This are the categories</h1>

      <p>One</p>
      <p>Two</p>


      </body>
      </html>
    HTML
  end
end
