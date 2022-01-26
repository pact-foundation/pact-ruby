source 'https://rubygems.org'

# Specify your gem's dependencies in pact.gemspec
gemspec

if ENV['X_PACT_DEVELOPMENT']
  gem "pact-support", path: '../pact-support'
  gem "pact-mock_service", path: '../pact-mock_service'
  gem "pry-byebug"
end

group :local_development do
  gem "pry-byebug"
end

gem 'pact-support', git: "https://github.com/Benjaminpjacobs/pact-support", ref: '189b4b2c148e04564d24afc6b81a83897cc78400'
gem "pact-mock_service", git: "https://github.com/Benjaminpjacobs/pact-mock_service", ref: "91d4e60ec7220b6614f9ef7dd4ba20316574138d"
