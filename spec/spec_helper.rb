ENV["RAILS_ENV"] = "test"

require 'byebug'
require 'dummy/config/environment'
require 'rspec/rails'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end
