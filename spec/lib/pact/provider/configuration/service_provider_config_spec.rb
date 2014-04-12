require 'spec_helper'
require 'pact/provider/configuration/service_provider_config'

module Pact
  module Provider
    module Configuration
      describe ServiceProviderConfig do

        describe "app" do

          subject { ServiceProviderConfig.new { Object.new } }

          it "should execute the app_block each time" do
            expect(subject.app.object_id).to_not equal(subject.app.object_id)
          end

        end
      end
    end
  end
end