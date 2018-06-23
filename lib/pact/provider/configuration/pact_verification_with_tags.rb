require 'pact/provider/pact_verification_with_tags'
require 'pact/provider/pact_uri'
require 'pact/shared/dsl'
require 'pact/provider/world'

module Pact
  module Provider

    module Configuration

      class PactVerificationWithTags

        extend Pact::DSL

        attr_accessor :tags, :pact_uri

        def initialize tags, options = {}
          @tags = tags
          @pact_uri = nil
        end

        dsl do
          def pact_uri pact_uri, options = {}
            self.pact_uri = ::Pact::Provider::PactURI.new(pact_uri, options) if pact_uri
          end
        end

        def finalize
          validate
          create_pact_verification
        end

        private

        def create_pact_verification
          verification = Pact::Provider::PactVerificationWithTags.new(tags, pact_uri)
          Pact.provider_world.add_pact_verification verification
        end

        def validate
          raise "Please provide a pact_uri for the verification" unless pact_uri
        end

      end
    end
  end
end