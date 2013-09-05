require 'fakefs/spec_helpers'
require 'rspec'
require 'pact'
require 'webmock/rspec'
require_relative 'support/factories'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do | config |
  config.include(FakeFS::SpecHelpers, :fakefs => true)
end
