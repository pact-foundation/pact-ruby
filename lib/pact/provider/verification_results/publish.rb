require 'json'
require 'pact/errors'

# TODO move this to the pact broker client
# TODO retries

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
          if can_publish_verification_results?
            tag_versions_if_configured
            publish_verification_results
          end
        end

        private

        def can_publish_verification_results?
          return false unless Pact.configuration.provider.publish_verification_results?

          if publication_url.nil?
            Pact.configuration.error_stream.puts "WARN: Cannot publish verification for #{consumer_name} as there is no link named pb:publish-verification-results in the pact JSON. If you are using a pact broker, please upgrade to version 2.0.0 or later."
            return false
          end

          if !verification_result.publishable?
            Pact.configuration.error_stream.puts "WARN: Cannot publish verification for #{consumer_name} as not all interactions have been verified. Re-run the verification without the filter parameters or environment variables to publish the verification."
            return false
          end
          true
        end

        def publication_url
          @publication_url ||= pact_source.pact_hash.fetch('_links', {}).fetch('pb:publish-verification-results', {})['href']
        end

        def tag_url tag
          # This is so dodgey, need to use proper HAL
          if publication_url
            u = URI(publication_url)
            if match = publication_url.match(%r{/provider/([^/]+)})
              provider_name = match[1]
              base_url = "#{u.scheme}://#{u.host}:#{u.host == u.default_port ? '' : u.port}"
              provider_application_version = Pact.configuration.provider.application_version
              "#{base_url}/pacticipants/#{provider_name}/versions/#{provider_application_version}/tags/#{tag}"
            end
          end
        end

        def tag_versions_if_configured
          if Pact.configuration.provider.tags.any?
            tag_versions if tag_url('')
          end
        end

        def tag_versions
          Pact.configuration.provider.tags.each do | tag |
            uri = URI(tag_url(tag))
            request = build_request('Put', uri, nil, "Tagging provider version at")
            response = nil
            begin
              options = {:use_ssl => uri.scheme == 'https'}
              response = Net::HTTP.start(uri.host, uri.port, options) do |http|
                http.request request
              end
            rescue StandardError => e
              error_message = "Failed to tag provider version due to: #{e.class} #{e.message}"
              raise PublicationError.new(error_message)
            end

            unless response.code.start_with?("2")
              raise PublicationError.new("Error returned from tagging request #{response.code} #{response.body}")
            end
          end
        end

        def publish_verification_results
          uri = URI(publication_url)
          request = build_request('Post', uri, verification_result.to_json, "Publishing verification result #{verification_result} to")
          response = nil
          begin
            options = {:use_ssl => uri.scheme == 'https'}
            response = Net::HTTP.start(uri.host, uri.port, options) do |http|
              http.request request
            end
          rescue StandardError => e
            error_message = "Failed to publish verification results due to: #{e.class} #{e.message}"
            raise PublicationError.new(error_message)
          end



          if response.code.start_with?("2")
            new_resource_url = JSON.parse(response.body)['_links']['self']['href']
            Pact.configuration.output_stream.puts "INFO: Verification results published to #{new_resource_url}"
          else
            raise PublicationError.new("Error returned from verification results publication #{response.code} #{response.body}")
          end
        end

        def build_request meth, uri, body, action
          request = Net::HTTP.const_get(meth).new(uri.path)
          request['Content-Type'] = "application/json"
          request.body = body if body
          debug_uri = uri
          if pact_source.uri.basic_auth?
            request.basic_auth pact_source.uri.username, pact_source.uri.password
            debug_uri = URI(uri.to_s).tap { |x| x.userinfo="#{pact_source.uri.username}:*****"}
          end
          Pact.configuration.output_stream.puts "INFO: #{action} #{debug_uri}"
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
