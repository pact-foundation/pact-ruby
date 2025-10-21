source 'https://rubygems.org'

# Specify your gem's dependencies in pact.gemspec
gemspec

# If rspec-mocks is not locked, spec/lib/pact/consumer/configuration_spec.rb fails on Ruby 3.0
# Should raise an issue, but no time right now.
# #<Pact::MockService::AppManager:0x00007fcf21410e68 @apps_spawned=false, @app_registrations=[]> received :register_mock_service_for with unexpected arguments
#   expected: ("Mock Provider", "http://localhost:1234", {:find_available_port=>false, :pact_specification_version=>"1"})
#        got: ("Mock Provider", "http://localhost:1234", {:find_available_port=>false, :pact_specification_version=>"1"})
# Diff:

gem "rspec-mocks", "3.13.6"
gem "appraisal", "~> 2.5"
gem "pact-support", git: "https://github.com/pact-foundation/pact-support.git", branch: "feat/generator_mock_server-url"

if ENV['X_PACT_DEVELOPMENT']
  gem "pact-support", path: '../pact-support'
  gem "pact-mock_service", path: '../pact-mock_service'
  gem "pry-byebug"
end

group :local_development do
  gem "pry-byebug"
end

group :test do
  gem 'faraday', '~>2.0', '<3.0'
  gem 'faraday-retry', '~>2.0'
  gem 'rackup'
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
end

if RUBY_VERSION >= "3.4"
  gem "csv"
  gem "mutex_m"
  gem "base64"
end
