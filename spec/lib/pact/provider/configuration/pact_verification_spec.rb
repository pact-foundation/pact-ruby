require 'spec_helper'
require 'pact/provider/configuration/pact_verification'

module Pact
  module Provider
    module Configuration
      describe PactVerification do

        describe 'create_verification' do
          let(:url) {'http://some/uri'}
          let(:consumer_name) {'some consumer'}
          let(:ref) {:prod}
          let(:options) { {:ref => :prod} }
          context "with valid values" do
            subject do
              uri = url
              PactVerification.build(consumer_name, options) do
                pact_uri uri
              end
            end

            it "creates a Verification" do
              Pact::Provider::PactVerification.should_receive(:new).with(consumer_name, url, ref)
              subject
            end
          end

          context "with a nil uri" do
            subject do
              PactVerification.build(consumer_name, options) do
                pact_uri nil
              end
            end

            it "raises a validation error" do
              expect{ subject }.to raise_error /Please provide a pact_uri/
            end
          end
        end
      end
    end
  end
end