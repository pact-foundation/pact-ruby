require 'pact/provider/pact_verification'
require 'pact/provider/pact_uri'
require 'pact/shared/dsl'
require 'pact/provider/world'

module Pact
  module Provider

    module Configuration

      class PactVerificationFromBroker

        extend Pact::DSL

        attr_accessor :name, :pact_broker_base_url, :tags

        def initialize(name, options = {})
          @tags = options.fetch(:consumer_version_tags) || []
          @pact_broker_base_url = options.fetch(:pact_broker_base_url) || ''
          @provider_name = name
          @options = options
        end

        dsl do
          def pact_broker_base_url pact_broker_base_url, options
            @pact_broker_base_url = URI(pact_broker_base_url)
            @pact_broker_base_url.set_user(options[:username]) if options[:username] # not sure about this exactly, I'll work it out when I get there.
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
            verification = Pact::Provider::PactVerification.new(nil, pact_uri, nil)
            Pact.provider_world.add_pact_verification verification
          end
        end

        def validate
          raise "Please provide a pact_broker_base_url for the verification" unless pact_broker_base_url
        end

      end
    end
  end
end