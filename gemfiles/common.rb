platform :ruby do
  gem 'yard'
  gem 'yard-tomdoc'
  gem 'redcarpet'
  gem 'github-markup'
  gem 'rails', require: false
  gem 'codeclimate-test-reporter', group: :test, require: nil
  gem 'ruby-beautify', '~> 0.97', require: false
end
