require 'pact/provider/configuration/service_provider_dsl'

module Pact

  module Provider

    module DSL
      def service_provider name, &block
        Configuration::ServiceProviderDSL.build(name, &block)
      end
    end
  end
end