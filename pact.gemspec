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
  gem.homepage      = "https://github.com/realestate-com-au/pact"

  gem.files         = `git ls-files bin lib pact.gemspec CHANGELOG.md LICENSE.txt`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license       = 'MIT'

  gem.add_runtime_dependency 'randexp', '~> 0.1.7'
  gem.add_runtime_dependency 'rspec', '>=2.14'
  gem.add_runtime_dependency 'rack-test', '~> 0.6.2'
  gem.add_runtime_dependency 'awesome_print', '~> 1.1'
  gem.add_runtime_dependency 'thor'
  gem.add_runtime_dependency 'json' #Not locking down a version because buncher gem requires 1.6, while other projects use 1.7.
  gem.add_runtime_dependency 'webrick'
  gem.add_runtime_dependency 'term-ansicolor', '~> 1.0'

  gem.add_runtime_dependency 'pact-support', '~> 0.5'
  gem.add_runtime_dependency 'pact-mock_service', '~> 0.7'

  gem.add_development_dependency 'rake', '~> 10.0.3'
  gem.add_development_dependency 'webmock', '~> 1.18.0'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'fakefs', '0.5' # 0.6.0 blows up
  gem.add_development_dependency 'hashie', '~> 2.0'
  gem.add_development_dependency 'activesupport'
  gem.add_development_dependency 'faraday'
  gem.add_development_dependency 'appraisal'
end
