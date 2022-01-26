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

gem 'pact-support', git: "https://github.com/joinhandshake/pact-support", ref: '0fa46bdaf27382a9eb86c9dfbcbca44d7b5e742c'
gem "pact-mock_service", git: "https://github.com/joinhandshake/pact-mock_service", ref: "1696b14465316dff565142714bf5443907208bde"