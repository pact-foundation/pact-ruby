source 'https://rubygems.org'

# Specify your gem's dependencies in pact.gemspec
gemspec

gem 'appraisal', '~> 2.5'

if ENV['X_PACT_DEVELOPMENT']
  gem 'pact-ffi', path: '../pact-ruby-ffi'
  gem 'pry-byebug'
end

group :local_development do
  gem 'pry-byebug'
end

group :test do
  gem 'faraday', '~>2.0', '<3.0'
  gem 'faraday-retry', '~>2.0'
  gem 'rackup'
  gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw]
end

if RUBY_VERSION >= '3.4'
  gem 'base64'
  gem 'csv'
  gem 'mutex_m'
end
