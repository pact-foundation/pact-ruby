require 'rspec'
require 'rspec/its'
require 'fakefs/spec_helpers'
require 'pact'
require 'webmock/rspec'
require 'support/factories'
require 'support/spec_support'
require 'pact/provider/rspec'

WebMock.disable_net_connect!(allow_localhost: true, allow: "https://www.google-analytics.com")

require './spec/support/active_support_if_configured'
require './spec/support/warning_silencer'

is_jruby = defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'

RSpec.configure do | config |
  config.include(FakeFS::SpecHelpers, fakefs: true)

  config.extend Pact::Provider::RSpec::ClassMethods
  config.include Pact::Provider::RSpec::InstanceMethods
  config.include Pact::Provider::TestMethods
  config.include Pact::SpecSupport
  if config.respond_to?(:example_status_persistence_file_path=)
    config.example_status_persistence_file_path = "./spec/examples.txt"
  end
  config.filter_run_excluding skip_jruby: is_jruby
end
