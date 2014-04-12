require 'pact/provider/configuration/dsl'
require 'pact/provider/configuration/configuration_extension'
require 'pact/provider/state/provider_state'

Pact.send(:extend, Pact::Provider::DSL)
Pact.send(:extend, Pact::Provider::State::DSL)
Pact::Configuration.send(:include, Pact::Provider::Configuration::ConfigurationExtension)