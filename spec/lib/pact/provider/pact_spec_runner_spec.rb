require 'pact/provider/pact_spec_runner'

describe Pact::Provider::PactSpecRunner do
  let(:options) { {provider: double(:provider)} }
  let(:pact_url) { double(:pact_url, uri: 'uri', options: {}) }
  let(:pact_urls) { [pact_url] }
  subject { described_class.new(pact_urls, options) }

  let(:interactions) do
    [{
       "description"    => "Description 1",
       "provider_state" => "there is an alligator named Mary",
       "request"        => {},
       "response"       => {
         "status" => 200,
       }
     }, {
       "description"    => "Description 2",
       "provider_state" => "there is not an alligator named Mary",
       "request"        => {},
       "response"       => {
         "status" => 200,
       }
     }, {
       "description"    => "Description 1",
       "provider_state" => "an error occurs retrieving an alligator",
       "request"        => {},
       "response"       => {
         "status" => 500,
       }
     }]
  end

  let(:pact_source) do
    double(:pact_source, uri: 'uri', pact_json: {"interactions" => interactions}.to_json)
  end

  describe '#run' do

    before do
      Pact.configuration.interactions_replay_order = interactions_replay_order
      Pact.service_provider "Fred" do
        app { "An app" }
      end
      allow(subject).to receive(:configure_rspec)
      allow(subject).to receive(:run_specs)

      expect(Pact::Provider::PactSource).to receive(:new).with(pact_url).and_return(pact_source)
    end

    context 'with multiple interactions' do
      let(:interactions_replay_order) { :recorded }

      it 'matches the original consumer interactions' do
        expect_any_instance_of(Array).to_not receive(:shuffle).and_call_original

        expect(subject).to receive(:honour_pactfile) do |_uri, pact_json, _options|
          consumer_contract = JSON.parse(pact_json)
          expect(consumer_contract["interactions"]).to eq(interactions)
        end

        subject.run
      end

      context 'and interactions_replay_order option set to random' do
        let(:interactions_replay_order) { :random }

        it 'randomised interactions within consumer contract' do
          allow(subject).to receive(:honour_pactfile).and_return([])
          expect_any_instance_of(Array).to receive(:shuffle).and_call_original

          subject.run
        end

        it 'does not change consumer interactions' do
          expect(subject).to receive(:honour_pactfile) do |_uri, pact_json, _options|
            consumer_contract = JSON.parse(pact_json)
            expect(consumer_contract["interactions"]).to match_array(interactions)
          end

          subject.run
        end
      end
    end

  end
end
