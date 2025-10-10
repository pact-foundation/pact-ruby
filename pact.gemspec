lib = File.expand_path("lib", __dir__)
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
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license       = 'MIT'

  gem.metadata = {
    'changelog_uri'     => 'https://github.com/pact-foundation/pact-ruby/blob/master/CHANGELOG.md',
    'source_code_uri'   => 'https://github.com/pact-foundation/pact-ruby',
    'bug_tracker_uri'   => 'https://github.com/pact-foundation/pact-ruby/issues',
    'documentation_uri' => 'https://github.com/pact-foundation/pact-ruby/blob/master/README.md'
  }

  # Shared dev dependencies between v1 and v2
  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'faraday', '~>2.0', '<3.0'
  gem.add_development_dependency 'webmock', '~> 3.0'

  # Shared runtime dependencies between v1 and v2
  gem.add_runtime_dependency 'rspec', '~> 3.0'

  # Pact v2 dependencies

  # Core dependencies (code loading)
  gem.add_dependency "zeitwerk", "~> 2.3"
  # For Pact support via Pact Rust Core
  gem.add_dependency "pact-ffi", "~> 0.4.28"
  # For Provider Side Verification
  gem.add_dependency "rack"
  gem.add_dependency "rack-proxy"
  gem.add_dependency "webrick", '~> 1.8'
  # For Rails support, including testing non rails apps
  gem.add_development_dependency "combustion", ">= 1.3"
  # For Kafka support
  unless RUBY_PLATFORM =~ /win32|x64-mingw32|x64-mingw-ucrt/
    # windows does not support librdkafka
    gem.add_development_dependency "sbmt-kafka_consumer", ">= 2.0.1"
    gem.add_development_dependency "sbmt-kafka_producer", ">= 1.0"
  end
  if ENV['X_PACT_DEVELOPMENT_RDKAFKA'] == 'true'
    # darwin-arm64 prebuilt gems available from 0.20.0
    gem.add_development_dependency "karafka-rdkafka", ">= 0.20.0"
  end 
  # For gRPC support
  gem.add_development_dependency "gruf", ">= 2.18"
  gem.add_development_dependency "gruf-rspec", ">= 0.6.0"
  # Testing tools
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rspec-rails"
  gem.add_development_dependency "rspec_junit_formatter"
  gem.add_development_dependency "vcr", ">= 6.0"
  # Development and linting tools
  gem.add_development_dependency "appraisal", ">= 2.4"
  gem.add_development_dependency "bundler", ">= 2.2"
  gem.add_development_dependency "rubocop"
  gem.add_development_dependency "rubocop-rspec"
  gem.add_development_dependency "rubocop-rails"
  gem.add_development_dependency "rubocop-performance"
  gem.add_development_dependency "standard", ">= 1.35.1"


  # Pact v1 dependencies
  gem.add_runtime_dependency 'rack-test', '>= 0.6.3', '< 3.0.0'
  gem.add_runtime_dependency 'thor', '>= 0.20', '< 2.0'
  gem.add_runtime_dependency "rainbow", '~> 3.1'
  gem.add_runtime_dependency 'string_pattern', '~> 2.0'
  gem.add_runtime_dependency 'jsonpath', '~> 1.0'

  gem.add_runtime_dependency "pact-support" , "~> 1.21", ">=1.21.2"
  gem.add_runtime_dependency 'pact-mock_service', '~> 3.0', '>= 3.3.1'
  gem.add_development_dependency 'fakefs', '2.4'
  gem.add_development_dependency 'hashie', '~> 5.0'
  gem.add_development_dependency 'faraday-multipart', '~> 1.0'
  gem.add_development_dependency 'conventional-changelog', '~> 1.3'
  gem.add_development_dependency 'bump', '~> 0.5'
  gem.add_development_dependency 'pact-message', '~> 0.8'
  gem.add_development_dependency 'rspec-its', '~> 1.3'
  # gem.add_development_dependency 'webrick', '~> 1.8' # webrick is a runtime dependency of pact v2, so included above
  gem.add_development_dependency 'ostruct'

end