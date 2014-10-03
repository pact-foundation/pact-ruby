module Pact
  module Test
    class CaseInsensitiveResponseHeadersApp

      def call env
        [200, {'cOnTent-tYpe' => 'application/hippo'},[]]
      end

    end
  end
end

Pact.service_provider "Provider" do
  app { Pact::Test::CaseInsensitiveResponseHeadersApp.new }
end