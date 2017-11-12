require 'json'

module Pact
  module Provider
    module VerificationResults
      class VerificationResult

        def initialize success, provider_application_version, test_results_hash
          @success = success
          @provider_application_version = provider_application_version
          @test_results_hash = test_results_hash
        end

        def provider_application_version_set?
          !!provider_application_version
        end

        def to_json
          {
            success: success,
            providerApplicationVersion: provider_application_version,
            testResults: test_results_hash
          }.to_json
        end

        def to_s
          "[success: #{success}, providerApplicationVersion: #{provider_application_version}]"
        end

        private

        attr_reader :success, :provider_application_version, :test_results_hash
      end
    end
  end
end
