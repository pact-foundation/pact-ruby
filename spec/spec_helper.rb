require 'rspec'
require 'rspec/fire'
require 'fakefs/spec_helpers'
require 'rspec'
require 'pact'
require 'webmock/rspec'
require_relative 'support/factories'

WebMock.disable_net_connect!(allow_localhost: true)

if ENV['LOAD_ACTIVE_SUPPORT']
   puts 'LOADING ACTIVE SUPPORT!!!! Hopefully it all still works'
   require 'active_support/all'
   require 'active_support'
   require 'active_support/json'
end

RSpec.configure do | config |
  config.include(FakeFS::SpecHelpers, :fakefs => true)
  config.include(RSpec::Fire)

  config.extend Pact::Provider::RSpec::ClassMethods
  config.include Pact::Provider::RSpec::InstanceMethods
  config.include Pact::Provider::TestMethods
end
