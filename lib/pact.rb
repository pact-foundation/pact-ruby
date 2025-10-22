require 'pact/support'
require 'pact/version'
require 'pact/configuration'
require 'pact/consumer'
require 'pact/provider'
require 'pact/consumer_contract'

begin
  require 'pact/v2'
rescue LoadError => e
  warn "Warning: Could not load 'pact/v2': #{e.message} \nPlease ensure that the 'pact-ffi' gem is included in your Gemfile for pact/v2 support."
end