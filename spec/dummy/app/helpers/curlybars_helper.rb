module CurlybarsHelper
  def beautify
    "bold#{yield}italic"
  end

  def form(path, opts)
    "beauty class:#{opts[:class]} foo:#{opts[:foo]} #{yield}"
  end

  def date(timestamp, opts)
    <<-HTML.strip_heredoc
      <time datetime="#{timestamp.strftime('%FT%H:%M:%SZ')}" class="#{opts[:class]}">
        #{timestamp.strftime('%B%e, %Y %H:%M')}
      </time>
    HTML
  end

  def asset(file_name)
    cdn_base_url = "http://cdn.example.com/"
    "#{cdn_base_url}#{file_name}"
  end

  def input(field, opts)
    type = opts.fetch(:title, 'text')
    <<-HTML.strip_heredoc
      <input name="#{field.name}" id="#{field.id}" type="#{type}" class="#{opts['class']}" value="#{field.value}">
    HTML
  end
end
