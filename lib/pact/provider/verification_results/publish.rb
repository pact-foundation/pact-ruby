require 'json'
require 'pact/errors'

module Pact
  module Provider
    module VerificationResults

      class PublicationError < Pact::Error; end

      class Publish

        def self.call pact_source, verification_result
          new(pact_source, verification_result).call
        end

        def initialize pact_source, verification_result
          @pact_source = pact_source
          @verification_result = verification_result
        end

        def call
          if Pact.configuration.provider.publish_verification_results?
            if publication_url
              publish
            else
              puts "WARNING: Cannot publish verification for #{consumer_name} as there is no link named pb:publish-verification-results in the pact JSON. If you are using a pact broker, please upgrade to version 2.0.0 or later."
            end
          end
        end

        private

        def publication_url
          @publication_url ||= pact_source.pact_hash.fetch('_links', {}).fetch('pb:publish-verification-results', {})['href']
        end

        def publish
          #TODO https
          #TODO username/password
          uri = URI(publication_url)
          request = build_request(uri)
          response = nil
          begin
            options = {:use_ssl => uri.scheme == 'https'}
            response = Net::HTTP.start(uri.host, uri.port, options) do |http|
              http.request request
            end
          rescue StandardError => e
            error_message = "Failed to publish verification result due to: #{e.class} #{e.message}"
            raise PublicationError.new(error_message)
          end

          unless response.code.start_with?("2")
            raise PublicationError.new("Error returned from verification result publication #{response.code} #{response.body}")
          end
        end

        def build_request uri
          request = Net::HTTP::Post.new(uri.path)
          request['Content-Type'] = "application/json"
          request.body = verification_result.to_json
          debug_uri = uri
          if pact_source.uri.basic_auth?
            request.basic_auth pact_source.uri.username, pact_source.uri.password
            debug_uri = URI(uri.to_s).tap { |x| x.userinfo="#{pact_source.uri.username}:*****"}
          end
          puts "Publishing verification result #{verification_result.to_json} to #{debug_uri}"
          request
        end

        def consumer_name
          pact_source.pact_hash['consumer']['name']
        end

        attr_reader :pact_source, :verification_result
      end
    end
  end
end
