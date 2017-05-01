require 'json'
require 'pact/errors'

module Pact
  module Provider
    module Verifications

      class PublicationError < Pact::Error; end

      class Publish

        CANNOT_PUBLISH_VERIFICATION_ERROR_MESSAGE = <<-EOM
Please set the provider application version in the Pact.service_provider block to enable verification results to be published to the pact broker.
eg.

Pact.service_provider "Foo" do
  app_version "1.2.#\{ENV.fetch('BUILD_NUMBER', 'dev')\}"
end

Alternatively, disable auto_publish_verifications by setting `auto_publish_verifications false`.

Pact.service_provider "Foo" do
  auto_publish_verifications false
end

EOM

        def self.call pact_json, verification
          new(pact_json, verification).call
        end

        def initialize pact_json, verification
          @pact_json = pact_json
          @verification = verification
        end

        def call
          if Pact.configuration.provider.auto_publish_verifications? && publication_url
            if verification.provider_application_version_set?
              publish
            else
              raise PublicationError.new(CANNOT_PUBLISH_VERIFICATION_ERROR_MESSAGE)
            end
          end
        end

        private

        def pact_hash
          @pact_hash ||= json_load(pact_json)
        end

        def json_load json
          JSON.load(json, nil, { max_nesting: 50 })
        end

        def publication_url
          @publication_url ||= pact_hash.fetch('_links', {}).fetch('pb:publish-verification', {})['href']
        end

        def publish
          #TODO https
          #TODO username/password
          puts "Publishing verification #{verification.to_json} to #{publication_url}"
          uri = URI(publication_url)
          request = Net::HTTP::Post.new(uri.path)
          request['Content-Type'] = "application/json"
          request.body = verification.to_json
          response = nil
          begin
            response = Net::HTTP.start(uri.host, uri.port) do |http|
              http.request request
            end
          rescue StandardError => e
            error_message = "Failed to publish verification due to: #{e.class} #{e.message}"
            raise PublicationError.new(error_message)
          end

          unless response.code.start_with?("2")
            raise PublicationError.new("Error returned from verification publication #{response.code} #{response.body}")
          end
        end

        attr_reader :pact_json, :verification
      end
    end
  end
end
