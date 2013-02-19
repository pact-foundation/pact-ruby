# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pact/version'

Gem::Specification.new do |gem|
  gem.name          = "pact"
  gem.version       = Pact::VERSION
  gem.authors       = ["James Fraser"]
  gem.email         = ["jfraser80@gmail.com"]
  gem.description   = %q{Define a pact between service consumers and providers}
  gem.summary       = %q{Define a pact between service consumers and providers}
  gem.homepage      = "https://git.realestate.com.au/business-systems/pact"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'randexp', '~> 0.1'
  gem.add_development_dependency 'rspec', '~> 2.12'
end
