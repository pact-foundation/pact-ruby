# frozen_string_literal: true

describe Pact::Provider::BaseVerifier do
  subject { described_class.new(Pact::Provider::PactConfig::Base.new(provider_name: 'provider')) }

  let(:build_selectors) { subject.send(:build_consumer_selectors, verify_only, consumer_name, consumer_branch) }

  context 'when verify_only is defined' do
    let(:verify_only) { %w[consumer-1 consumer-2] }

    context 'when consumer / branch are defined and matched' do
      let(:consumer_name) { 'consumer-1' }
      let(:consumer_branch) { '32b53c01' }

      it 'builds proper selectors' do
        expect(build_selectors).to eq([{ 'branch' => '32b53c01', 'consumer' => 'consumer-1' }])
      end
    end

    context 'when consumer / branch are defined and not matched' do
      let(:consumer_name) { 'consumer-3' }
      let(:consumer_branch) { 'feature-branch' }

      it 'builds proper selectors' do
        expect(build_selectors).to be_empty
      end
    end

    context 'when consumer is not defined' do
      let(:consumer_name) { nil }
      let(:consumer_branch) { nil }

      it 'builds proper selectors' do
        expect(build_selectors)
          .to eq([
                   { 'consumer' => 'consumer-1' },
                   { 'consumer' => 'consumer-2' }
                 ])
      end
    end
  end

  context 'when verify_only is not defined' do
    let(:verify_only) { [] }

    context 'when consumer / branch are defined' do
      let(:consumer_name) { 'consumer-1' }
      let(:consumer_branch) { '32b53c01' }

      it 'builds proper selectors' do
        expect(build_selectors).to eq([{ 'branch' => '32b53c01', 'consumer' => 'consumer-1' }])
      end
    end

    context 'when only consumer is defined' do
      let(:consumer_name) { 'consumer-3' }
      let(:consumer_branch) { nil }

      it 'builds proper selectors' do
        expect(build_selectors).to eq([{ 'consumer' => 'consumer-3' }])
      end
    end

    context 'when consumer is not defined' do
      let(:consumer_name) { nil }
      let(:consumer_branch) { nil }

      it 'builds proper selectors' do
        expect(build_selectors).to eq([{}])
      end
    end
  end
end
