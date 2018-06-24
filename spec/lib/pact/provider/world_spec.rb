require 'spec_helper'
load 'pact/provider/world.rb'

describe Pact do
  describe ".provider_world" do
    it "returns a world" do
      expect(Pact.provider_world).to be_instance_of Pact::Provider::World
    end
    it "returns the same world each time" do
      expect(Pact.provider_world).to be Pact.provider_world
    end
  end

  describe ".clear_provider_world" do
    it "clears the world" do
      original_world = Pact.provider_world
      Pact.clear_provider_world
      expect(original_world).to_not be Pact.provider_world
    end
  end

end

module Pact
  module Provider
    describe World do

      subject { World.new }

      describe "provider_states" do
        it "returns a provider state proxy" do
          expect(subject.provider_states).to be_instance_of State::ProviderStateProxy
        end
        it "returns the same object each time" do
          expect(subject.provider_states).to be subject.provider_states
        end
      end

      describe "pact_urls" do
        context "with pact_uri_sources" do
          before do
            subject.add_pact_uri_source(pact_uri_source_1)
            subject.add_pact_uri_source(pact_uri_source_2)
          end

          let(:pact_uri_source_1) { double('pact_uri_source_1', call: ["uri-1"]) }
          let(:pact_uri_source_2) { double('pact_uri_source_2', call: ["uri-2"]) }

          let(:pact_urls) { subject.pact_urls }

          it "invokes call on the pact_uri_sources" do
            expect(pact_uri_source_1).to receive(:call)
            expect(pact_uri_source_2).to receive(:call)
            pact_urls
          end

          it "concatenates the results" do
            expect(pact_urls).to eq ["uri-1", "uri-2"]
          end

          context "with a pact_verification" do
            before do
              subject.add_pact_verification(pact_verification)
            end

            let(:pact_verification) { double('PactVerification', uri: "uri-3") }

            it "concatenates the results with those of the pact_uri_sources" do
              expect(pact_urls).to eq ["uri-3", "uri-1", "uri-2"]
            end
          end
        end
      end
    end
  end
end
