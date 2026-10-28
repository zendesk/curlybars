SimpleCov.configure do
  enable_coverage :branch
  coverage :branch do
    ignore :implicit_else
  end

  skip "/spec/"

  # Raise these towards 100% as coverage improves.
  minimum_coverage line: 94.4, branch: 84.4
end
