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

gem 'pact-support', git: "https://github.com/Benjaminpjacobs/pact-support", ref: 'cfa90871707c28d8ec46f323fbaf0c3e61a54066'
gem "pact-mock_service", git: "https://github.com/Benjaminpjacobs/pact-mock_service", ref: "7952006a2b4ea8868d02b52e4c89218d4a5a6479"
