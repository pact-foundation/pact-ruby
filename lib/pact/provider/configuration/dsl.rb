require 'pact/provider/configuration/service_provider_dsl'
require 'pact/provider/configuration/message_provider_dsl'

module Pact

  module Provider

    module DSL
      def service_provider name, &block
        Configuration::ServiceProviderDSL.build(name, &block)
      end

      def message_provider name, &block
        Configuration::MessageProviderDSL.build(name, &block)
      end
    end
  end
end
