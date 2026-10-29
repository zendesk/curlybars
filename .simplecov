SimpleCov.configure do
  enable_coverage :branch
  coverage :branch do
    ignore :implicit_else
  end

  skip "/spec/"

  minimum_coverage line: 100, branch: 100
end
