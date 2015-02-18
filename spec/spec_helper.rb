require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

ENV["RAILS_ENV"] = "test"

require 'byebug'
require 'dummy/config/environment'
require 'rspec/rails'

require 'curlybars/lexer'
require 'curlybars/parser'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end
