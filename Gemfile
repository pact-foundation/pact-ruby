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

gem 'pact-support', git: "https://github.com/Benjaminpjacobs/pact-support", ref: 'b688d0f87871a96bfdae3ba810bf5b40d4344d14'
gem "pact-mock_service", git: "https://github.com/Benjaminpjacobs/pact-mock_service", ref: "0800002a732332c377ba5aaea36af4a80c8e6dc2"
