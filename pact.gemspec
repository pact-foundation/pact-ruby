# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pact/version'

Gem::Specification.new do |gem|
  gem.name          = "pact"
  gem.version       = Pact::VERSION
  gem.authors       = ["James Fraser", "Sergei Matheson", "Brent Snook", "Ronald Holshausen", "Beth Skurrie"]
  gem.email         = ["james.fraser@alumni.swinburne.edu", "sergei.matheson@gmail.com", "brent@fuglylogic.com", "uglyog@gmail.com", "bskurrie@dius.com.au"]
  gem.description   = %q{Enables consumer driven contract testing, providing a mock service and DSL for the consumer project, and interaction playback and verification for the service provider project.}
  gem.summary       = %q{Enables consumer driven contract testing, providing a mock service and DSL for the consumer project, and interaction playback and verification for the service provider project.}
  gem.homepage      = "https://github.com/pact-foundation/pact-ruby"

  gem.required_ruby_version = '>= 2.0'

  gem.files         = `git ls-files bin lib pact.gemspec CHANGELOG.md LICENSE.txt`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license       = 'MIT'

  gem.add_runtime_dependency 'randexp', '~> 0.1.7'
  gem.add_runtime_dependency 'rspec', '>=2.14'
  gem.add_runtime_dependency 'rack-test', '~> 0.6', '>= 0.6.3'
  gem.add_runtime_dependency 'thor'
  gem.add_runtime_dependency 'json','> 1.8.5'
  gem.add_runtime_dependency 'webrick'
  gem.add_runtime_dependency 'term-ansicolor', '~> 1.0'

  gem.add_runtime_dependency 'pact-support', '~> 1.8'
  gem.add_runtime_dependency 'pact-mock_service', '~> 2.10'

  gem.add_development_dependency 'rake', '~> 10.0.3'
  gem.add_development_dependency 'webmock', '~> 3.0'
  #gem.add_development_dependency 'pry-byebug'
  gem.add_development_dependency 'fakefs', '0.5' # 0.6.0 blows up
  gem.add_development_dependency 'hashie', '~> 2.0'
  gem.add_development_dependency 'activesupport'
  gem.add_development_dependency 'faraday', '~> 0.13'
  gem.add_development_dependency 'appraisal', '~> 2.2'
  gem.add_development_dependency 'conventional-changelog', '~> 1.3'
  gem.add_development_dependency 'bump', '~> 0.5'
end
