# frozen_string_literal: true

require "rack-proxy"

module Pact
  module V2
    module Provider
      class PactBrokerProxy < Rack::Proxy
        attr_reader :backend_uri, :path, :logger

        # e.g. /pacts/provider/paas-stand-seeker/consumer/paas-stand-placer/pact-version/2967a9343bd8fdd28a286c4b8322380020618892/metadata/c1tdW2VdPXByb2R1Y3Rpb24mc1tdW2N2XT03MzIy
        PACT_FILE_REQUEST_PATH_REGEX = %r{/pacts/provider/.+?/consumer/.+?/pact-version/.+}.freeze

        def initialize(app = nil, opts = {})
          super
          @backend_uri = URI(opts[:backend])
          @path = nil
          @logger = opts[:logger] || Logger.new($stdout)
        end

        def perform_request(env)
          request = Rack::Request.new(env)
          env["rack.timeout"] ||= ENV.fetch("PACT_BROKER_REQUEST_TIMEOUT", 5).to_i
          @path = request.path

          super
        end

        def rewrite_env(env)
          env["HTTP_HOST"] = backend_uri.host
          env
        end

        def rewrite_response(triplet)
          status, headers, body = triplet

          if status == "200" && PACT_FILE_REQUEST_PATH_REGEX.match?(path)
            patched_body = patch_response(body.first)

            # we need to recalculate content length
            headers[Rack::CONTENT_LENGTH] = patched_body.bytesize.to_s

            return [status, headers, [patched_body]]
          end

          triplet
        end

        private

        def patch_response(raw_body)
          parsed_body = JSON.parse(raw_body)

          return body if parsed_body["consumer"].blank? || parsed_body["provider"].blank?
          return body if parsed_body["interactions"].blank?


          JSON.generate(parsed_body)
        rescue JSON::ParserError => ex
          logger.error("cannot parse broker response: #{ex.message}")
        end


        def set_description_prefix(interaction, prefix)
          orig_description = interaction["description"]
          interaction["description"] = "#{prefix} #{orig_description}" unless orig_description.start_with?(prefix)
        end
      end
    end
  end
end
