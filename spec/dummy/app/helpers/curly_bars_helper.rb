module CurlyBarsHelper
  def beautify(path, opts={})
    "bold#{yield}italic from: #{path}"
  end

  def form(path, opts={})
    "beauty #{path} class:#{opts[:class]} foo:#{opts[:foo]} #{yield}"
  end
end
