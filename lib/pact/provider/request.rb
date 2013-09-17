require 'json'
require 'pact/reification'
require 'pact/shared/null_expectation'

module Pact
  module Provider
    module Request
      class Replayable

        def initialize expected_request
          @expected_request = expected_request
        end

        def method
          expected_request.method
        end

        def path
          expected_request.full_path
        end

        def body
          case expected_request.body
          when String then expected_request.body
          when NullExpectation then ''
          else
            reified_body
          end
        end

        def headers
          request_headers = {}
          return request_headers if expected_request.headers.is_a?(Pact::NullExpectation)
          expected_request.headers.each do |key, value|
            key = key.upcase
            if key.match(/CONTENT.TYPE/)
              request_headers['CONTENT_TYPE'] = value
            else
              request_headers['HTTP_' + key.to_s] = value
            end
          end
          request_headers
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
      end      
    end
  end
end