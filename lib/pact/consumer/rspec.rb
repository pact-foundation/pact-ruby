require_relative '../configuration'
require_relative '../consumer'
require_relative 'dsl'
require_relative 'configuration_dsl'

module Pact
  module Consumer
    module RSpec
      include Pact::Consumer::ConsumerContractBuilders
    end
  end
end

RSpec.configure do |config|
  config.include Pact::Consumer::RSpec, :pact => true

  config.before :all, :pact => true do
    Pact::Consumer::AppManager.instance.spawn_all
    FileUtils.mkdir_p Pact.configuration.pact_dir
  end

  config.before :each, :pact => true do
    Pact.configuration.logger.info "Clearing all expectations"
    Pact::Consumer::AppManager.instance.ports_of_mock_services.each do | port |
      Net::HTTP.new("localhost", port).delete("/interactions")
    end
  end

  config.after :each, :pact => true do | example |
    example_description = "#{example.example.example_group.description} #{example.example.description}"
    Pact.configuration.logger.info "Verifying interactions for #{example_description}"
    Pact.configuration.producer_verifications.each do | producer_verification |
      producer_verification.call example_description
    end
  end

  config.after :suite do
    Pact.configuration.logger.info "After suite"
    Pact::Consumer::AppManager.instance.kill_all
    Pact::Consumer::AppManager.instance.clear_all
  end
end
