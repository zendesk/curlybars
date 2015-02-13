describe "Using Curly(bars) for the application layout", type: :request do
  example "A simple layout view in Curly" do
    get '/'

    response.body.should == <<-HTML.strip_heredoc
      <html>
      <head>
        <title>Dummy app</title>
      </head>
      <body>
      <h1>Dashboard</h1>
      <p>Hello, World!</p>
      <p>Welcome!</p>

      </body>
      </html>
    HTML
  end

  example "A simple layout view in Curlybars" do
    get '/articles/1'

    response.body.should == <<-HTML.strip_heredoc
      <html>
      <head>
        <title>Dummy app</title>
      </head>
      <body>
      <p>Hi Admin</p>

      <h1>Article: The Prince</h1>


      <p>
        author Nicolò
        <img src="http://example.com/foo.png" />
      </p>


      </body>
      </html>
    HTML
  end
end
