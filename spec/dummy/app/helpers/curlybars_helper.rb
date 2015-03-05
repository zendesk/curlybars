module CurlybarsHelper
  def beautify
    "bold#{yield}italic"
  end

  def form(context, options)
    "beauty class:#{options[:class]} foo:#{options[:foo]} #{yield}"
  end

  def date(context, options)
    <<-HTML.strip_heredoc
      <time datetime="#{context.strftime('%FT%H:%M:%SZ')}" class="#{options[:class]}">
        #{context.strftime('%B%e, %Y %H:%M')}
      </time>
    HTML
  end

  def asset(context)
    cdn_base_url = "http://cdn.example.com/"
    "#{cdn_base_url}#{context}"
  end

  def input(context, options)
    type = options.fetch(:title, 'text')
    <<-HTML.strip_heredoc
      <input name="#{context.name}" id="#{context.id}" type="#{type}" class="#{options['class']}" value="#{context.value}">
    HTML
  end
end
