require 'pact/doc/generate'

module Pact
  module Consumer
    class SpecHooks

      def before_all
        Pact::Consumer::AppManager.instance.spawn_all
        FileUtils.mkdir_p Pact.configuration.pact_dir
      end

      def before_each example_description
        Pact.configuration.logger.info "Clearing all expectations"
        Pact::Consumer::AppManager.instance.ports_of_mock_services.each do | port |
          Pact::Consumer::MockServiceClient.clear_interactions port, example_description
        end
      end

      def after_each example_description
        Pact.configuration.logger.info "Verifying interactions for #{example_description}"
        Pact.configuration.provider_verifications.each do | provider_verification |
          provider_verification.call example_description
        end
      end

      def after_suite
        Pact::Doc::Generate.call
        Pact.configuration.logger.info "After suite"
        Pact::Consumer::AppManager.instance.kill_all
        Pact::Consumer::AppManager.instance.clear_all
      end
    end
  end
end