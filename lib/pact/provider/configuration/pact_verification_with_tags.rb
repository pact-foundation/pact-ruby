require 'pact/provider/pact_verification_with_tags'
require 'pact/provider/pact_uri'
require 'pact/shared/dsl'
require 'pact/provider/world'

module Pact
  module Provider

    module Configuration

      class PactVerificationWithTags

        extend Pact::DSL

        attr_accessor :name, :pact_broker_base_url, :tags, :pact_uri

        def initialize(name, options = {})
          puts options
          @tags = options.fetch(:consumer_version_tags) || []
          @pact_broker_base_url = options.fetch(:pact_broker_base_url)
          @provider_name = name
          @options = options
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
          pacts = Pact::PactBroker::FetchPacts.call(@provider_name, tags, pact_broker_base_url, @options)
          pacts.each do |pact_uri|
            verification = Pact::Provider::PactVerificationWithTags.new(pact_uri)
            Pact.provider_world.add_pact_verification verification
          end
        end

        def validate
          raise "Please provide a pact_uri for the verification" unless pact_uri
        end

      end
    end
  end
end