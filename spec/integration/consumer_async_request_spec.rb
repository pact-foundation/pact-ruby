require 'spec_helper'
require 'pact/consumer'
require 'pact/consumer/rspec'
load 'pact/consumer/world.rb'

describe "A service consumer side of a pact", :pact => true  do

  context "with an asynchronous interaction with provider" do
    before do
      Pact.clear_configuration

      Pact.service_consumer "Consumer" do
        has_pact_with "Zebra Service" do
          mock_service :zebra_service do
            verify true
            port 1239
          end
        end
      end
    end

    it "goes like this" do
      zebra_service.
        given(:the_zebras_are_here).
        upon_receiving("a retrieve Mallory request").
      with({
             method: :get,
             path: '/mallory'
      }).
        will_respond_with({status: 200})

      async_interaction { Net::HTTP.get_response(URI('http://localhost:1239/mallory')) }

      zebra_service.wait_for_interactions wait_max_seconds: 1, poll_interval: 0.1
    end

    def async_interaction
      Thread.new do
        sleep 0.2
        yield
      end
    end

  end

end
