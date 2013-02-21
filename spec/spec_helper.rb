require 'rspec'
require 'pact'
require 'webmock/rspec'
require_relative 'matchers'

WebMock.disable_net_connect!(allow_localhost: true)
