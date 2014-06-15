require 'spec_helper'
require 'pact/consumer/mock_service/control_server'
require 'rack/test'

module Pact
  module Consumer

    describe ControlServer do

      describe "call" do

        let(:log_file) { double("log_file").as_null_object }
        let(:options) { {log_file: log_file} }
        let(:success_response) { [200, {}, []]}

        let(:app) { ControlServer.new options }

        context "when the path is POST /mock-services" do

          it "creates a new mock-service" do
            allow_any_instance_of(SetUpMockService).to receive(:call).and_return(success_response)
            post "/mock-services", '', {'HTTP_X_PACT_MOCK_SERVICE' => true}
            expect(last_response.status).to eq 200
          end

        end
      end

    end
  end
end