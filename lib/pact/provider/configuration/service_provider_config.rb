module Pact
  module Provider
    module Configuration
      class ServiceProviderConfig

        attr_accessor :application_version
        attr_reader :branch

        def initialize application_version, branch, tags, publish_verification_results, &app_block
          @application_version = application_version
          @branch = branch
          @tags = [*tags]
          @publish_verification_results = publish_verification_results
          @app_block = app_block
        end

        def app
          @app_block.call
        end

        def publish_verification_results?
          @publish_verification_results
        end

        def tags
          @tags
        end
      end
    end
  end
end