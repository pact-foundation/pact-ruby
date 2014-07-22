require 'spec_helper'
require 'pact/consumer/mock_service_interaction_expectation'

describe Pact::Consumer::MockServiceInteractionExpectation do
  describe "as_json" do

    let(:request_options ) { {} }
    let(:request_as_json) { {a: 'request'} }
    let(:request) { instance_double('Pact::Request::Expected', :as_json => request_as_json, :options => request_options)}
    let(:response) { double('response') }
    let(:generated_response ) { double('generated_response', :to_json => 'generated_response') }
    let(:interaction) { instance_double('Pact::Interaction', :description => 'description', :request => request, :response => response, :provider_state => 'some state') }
    subject { described_class.new(interaction, mock_service_host)}
    let(:expected_hash) { {:response => generated_response, :request => as_json_with_options, :description => '' } }
    let(:mock_service_host) { 'localhost:1234'}
    let(:response_options) { nil }

    before do
      allow(response).to receive(:delete).and_return(response_options)
    end

    it "includes the response" do
      expect(subject.as_json[:response]).to eq response
    end

    it "includes the options in the request" do
      expect(subject.as_json[:request]).to eq request_as_json
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

    context "without options" do
      it "does not include the options key" do
        expect(subject.as_json.key?(:options)).to be false
      end
    end

    context "with request options" do
      let(:request_options) { {:opts => 'blah'} }
      it "includes the options in the request hash" do
        expect(subject.as_json[:request][:options]).to eq request_options
      end
    end

    context "with response options" do
      let(:response_options) { {host_alias: 'example.org'} }
      let(:hypermediafied_object_tree) { double('hypermediafied_object_tree')}

      before do
        allow(Pact::HypermediafyObjectTree).to receive(:call).and_return(hypermediafied_object_tree)
      end
      it "deletes the options from the response" do
        expect(response).to receive(:delete).with(:options)
        subject.as_json
      end
      it "replaces instances of the host_alias with a Pact::Term" do
        expect(Pact::HypermediafyObjectTree).to receive(:call).with(instance_of(Hash),'example.org', mock_service_host)
        expect(subject.as_json).to be hypermediafied_object_tree
      end
    end

  end

end