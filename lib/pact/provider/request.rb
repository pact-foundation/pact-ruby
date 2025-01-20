require 'json'
require 'pact/reification'
require 'pact/shared/null_expectation'
require 'pact/generators'

module Pact
  module Provider
    module Request
      class Replayable

        # See https://github.com/rack/rack/blob/e7d741c6282ca4cf4e01506f5681e6e6b14c0b32/SPEC#L87-89
        NO_HTTP_PREFIX = ["CONTENT-TYPE", "CONTENT-LENGTH"]

        def initialize expected_request, state_params = nil
          @expected_request = expected_request
          @state_params = state_params
        end

        def method
          expected_request.method
        end

        def path
          Pact::Generators.apply_generators(expected_request, "path", expected_request.full_path, @state_params)
        end

        def body
          case expected_request.body
          when String then expected_request.body
          when NullExpectation then ''
          else
            Pact::Generators.apply_generators(expected_request, "body", reified_body, @state_params)
          end
        end

        def headers
          request_headers = {}
          # https://github.com/pact-foundation/pact-ruby/pull/327
          request_headers.merge!('HOST' => 'localhost') if defined?(Sinatra)
          return request_headers if expected_request.headers.is_a?(Pact::NullExpectation)

          expected_request.headers.each do |key, value|
            request_headers[key] = Pact::Reification.from_term(value)
          end

          request_headers = Pact::Generators.apply_generators(expected_request, "header", request_headers, @state_params)
          request_headers.map{ |key,value| [rack_request_header_for(key), value]}.to_h
        end

        private

        attr_reader :expected_request

        def reified_body
          rb = Pact::Reification.from_term(expected_request.body)
          if rb.is_a?(String)
            rb
          else
            JSON.dump(rb)
          end
        end

        def rack_request_header_for header
          with_http_prefix(header.to_s.upcase).tr('-', '_')
        end

        def rack_request_value_for value
          Array(value).join("\n")
        end

        def with_http_prefix header
          NO_HTTP_PREFIX.include?(header) ? header : "HTTP_#{header}"
        end
      end
    end
  end
end
