module CurlybarsHelper
  def beautify(path, opts={})
    "bold#{yield}italic"
  end

  def form(path, opts={})
    "beauty class:#{opts[:class]} foo:#{opts[:foo]} #{yield}"
  end
end
