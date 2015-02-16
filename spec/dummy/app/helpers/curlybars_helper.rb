module CurlybarsHelper
  def beautify
    "bold#{yield}italic"
  end

  def form(path, opts)
    "beauty class:#{opts[:class]} foo:#{opts[:foo]} #{yield}"
  end

  def date(timestamp, opts)
    <<-HTML.strip_heredoc
      <time datetime="#{timestamp.strftime("%FT%H:%M:%SZ")}" class="#{opts[:class]}">
        #{timestamp.strftime("%B%e, %Y %H:%M")}
      </time>
    HTML
  end
end
