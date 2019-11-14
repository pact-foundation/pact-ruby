require 'pact/doc/generate'
require 'pact/consumer/world'
require 'pact/mock_service/app_manager'
require 'pact/mock_service/client'

module Pact
  module Consumer
    class SpecHooks

      def before_all
        Pact::MockService::AppManager.instance.spawn_all
        FileUtils.mkdir_p Pact.configuration.pact_dir
      end

      def before_each example_description
        Pact.consumer_world.register_pact_example_ran
        Pact.configuration.logger.info "Clearing all expectations"
        Pact::MockService::AppManager.instance.urls_of_mock_services.each do | url |
          Pact::MockService::Client.clear_interactions url, example_description
        end
      end

      def after_each example_description
        Pact.configuration.logger.info "Verifying interactions for #{example_description}"
        Pact.configuration.provider_verifications.each do | provider_verification |
          provider_verification.call example_description
        end
      end

      def after_suite
        if Pact.consumer_world.any_pact_examples_ran?
          Pact.consumer_world.consumer_contract_builders.each(&:write_pact)
          Pact::Doc::Generate.call
          Pact::MockService::AppManager.instance.kill_all
          Pact::MockService::AppManager.instance.clear_all
        end
      end
    end
  end
end
