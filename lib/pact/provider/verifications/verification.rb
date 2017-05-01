module Pact
  module Provider
    module Verifications
      class Verification

        def initialize success, provider_application_version
          @success = success
          @provider_application_version = provider_application_version
        end

        def provider_application_version_set?
          !!provider_application_version
        end

        def to_json
          {
            success: success,
            providerApplicationVersion: provider_application_version
          }.to_json
        end

        private

        attr_reader :success, :provider_application_version
      end
    end
  end
end
