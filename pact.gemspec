# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pact/version'

Gem::Specification.new do |gem|
  gem.name          = "pact"
  gem.version       = Pact::VERSION
  gem.authors       = ["James Fraser", "Sergei Matheson", "Brent Snook"]
  gem.email         = ["james.fraser@alumni.swinburne.edu", "sergei.matheson@gmail.com", "brent@fuglylogic.com"]
  gem.description   = %q{Define a pact between service consumers and providers}
  gem.summary       = %q{Define a pact between service consumers and providers}
  gem.homepage      = "https://git.realestate.com.au/business-systems/pact"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'randexp', '~> 0.1.7'
  gem.add_runtime_dependency 'hashie', '~> 1.2.0'
  gem.add_runtime_dependency 'rspec', '~> 2.12.0'
  gem.add_runtime_dependency 'find_a_port', '~> 1.0.1'
  gem.add_development_dependency 'capybara', '~> 2.0.0'
  gem.add_development_dependency 'rake', '~> 10.0.3'
  gem.add_development_dependency 'webmock', '~> 1.9.3'
end
