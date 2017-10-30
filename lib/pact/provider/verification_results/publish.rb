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
          if Pact.configuration.provider.publish_verification_results?
            if tag_url('')
              tag
            else
              Pact.configuration.error_stream.puts "WARN: Cannot tag provider version as there is no link named pb:tag-version in the pact JSON."
            end
            if publication_url
              publish
            else
              Pact.configuration.error_stream.puts "WARN: Cannot publish verification for #{consumer_name} as there is no link named pb:publish-verification-results in the pact JSON. If you are using a pact broker, please upgrade to version 2.0.0 or later."
            end
          end
        end

        private

        def publication_url
          @publication_url ||= pact_source.pact_hash.fetch('_links', {}).fetch('pb:publish-verification-results', {})['href']
        end

        def tag_url tag
          href = pact_source.pact_hash.dig('_links', 'pb:tag-version', 'href')
          href ? href.gsub('{tag}', tag) : nil
        end

        def tag
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

        def publish
          uri = URI(publication_url)
          request = build_request('Post', uri, verification_result.to_json, "Publishing verification result #{verification_result.to_json} to")
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
