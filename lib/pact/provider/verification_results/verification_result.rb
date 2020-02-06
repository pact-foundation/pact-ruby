require 'json'

module Pact
  module Provider
    module VerificationResults
      class VerificationResult
        attr_reader :success, :provider_application_version, :test_results_hash

        def initialize publishable, success, provider_application_version, test_results_hash
          @publishable = publishable
          @success = success
          @provider_application_version = provider_application_version
          @test_results_hash = test_results_hash
        end

        def publishable?
          @publishable
        end

        def provider_application_version_set?
          !!provider_application_version
        end

        def to_json(options = {})
          {
            success: success,
            providerApplicationVersion: provider_application_version,
            testResults: test_results_hash
          }.to_json(options)
        end

        def to_s
          "[success: #{success}, providerApplicationVersion: #{provider_application_version}]"
        end
      end
    end
  end
end
