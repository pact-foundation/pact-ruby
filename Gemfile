source 'https://rubygems.org'

# Specify your gem's dependencies in pact.gemspec
gemspec

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
