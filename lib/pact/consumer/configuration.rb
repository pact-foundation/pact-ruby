require 'pact/configuration'
require 'pact/consumer/consumer_contract_builders'
require 'pact/consumer/consumer_contract_builder'
require 'pact/consumer/configuration/service_consumer'
require 'pact/consumer/configuration/service_provider'
require 'pact/consumer/configuration/dsl'
require 'pact/consumer/configuration/configuration_extensions'

Pact.send(:extend, Pact::Consumer::DSL)
Pact::Configuration.send(:include, Pact::Consumer::Configuration::ConfigurationExtensions)