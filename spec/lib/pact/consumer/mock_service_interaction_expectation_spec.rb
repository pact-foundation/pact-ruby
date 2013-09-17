require 'spec_helper'
require 'pact/consumer/mock_service_interaction_expectation'

describe Pact::Consumer::MockServiceInteractionExpectation do
  describe "as_json" do
    let(:as_json_with_options ) { {:opts => 'blah'} }
    let(:request) { instance_double('Pact::Request::Expected', :as_json_with_options => {:opts => 'blah'})}
    let(:response) { double('response') }
    let(:generated_response ) { double('generated_response', :to_json => 'generated_response') }
    let(:interaction) { instance_double('Pact::Interaction', :description => 'description', :request => request, :response => response, :provider_state => 'some state') }
    subject { described_class.new(interaction)}
    let(:expected_hash) { {:response => generated_response, :request => as_json_with_options, :description => '' } }

    before do
      Pact::Reification.stub(:from_term).with(response).and_return(generated_response)
    end

    it "generates an actual response" do
      Pact::Reification.should_receive(:from_term).with(response).and_return(generated_response)
      expect(subject.as_json[:response]).to eq generated_response
    end

    it "includes the options in the request" do
      expect(subject.as_json[:request]).to eq as_json_with_options
    end

    it "includes the provider state" do
      expect(subject.as_json[:provider_state]).to eq 'some state'
    end

    it "includes the description" do
      expect(subject.as_json[:description]).to eq 'description'
    end

    it "doesn't have any other keys" do
      expect(subject.as_json.keys).to eq [:description, :provider_state, :request, :response]
    end
  end
   
end