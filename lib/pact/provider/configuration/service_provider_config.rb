module Pact
  module Provider
    module Configuration
      class ServiceProviderConfig

        attr_accessor :application_version

        def initialize application_version, publish_verifications, &app_block
          @application_version = application_version
          @publish_verifications = publish_verifications
          @app_block = app_block
        end

        def app
          @app_block.call
        end

        def publish_verifications?
          @publish_verifications
        end
      end
    end
  end
end