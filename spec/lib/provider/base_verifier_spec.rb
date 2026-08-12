# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'

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

  describe '#configure_verification_source' do
    let(:consumer_version_selectors) do
      [
        { 'branch' => 'main' },
        { 'deployedOrReleased' => true }
      ]
    end
    let(:config) do
      Pact::Provider::PactConfig::Base.new(
        provider_name: 'provider',
        opts: {
          broker_url: 'http://broker.example',
          consumer_version_selectors: consumer_version_selectors
        }
      )
    end
    let(:handle) { Object.new }

    subject(:verifier) { described_class.new(config) }

    it 'passes configured consumer version selectors to the broker source' do
      expect(PactFfi::Verifier).to receive(:broker_source_with_selectors) do |*_args|
        expect(_args[11]).to eq(consumer_version_selectors.size)
      end

      verifier.send(:configure_verification_source, handle, nil, 0, nil, 0)
    end
  end

  describe '#ensure_provider_has_matching_pacts!' do
    let(:provider_name) { 'expected-provider' }
    let(:opts) { { fail_if_no_pacts_found: fail_if_no_pacts_found } }
    let(:fail_if_no_pacts_found) { true }
    let(:config) { Pact::Provider::PactConfig::Base.new(provider_name: provider_name, opts: opts) }
    subject(:verifier) { described_class.new(config) }

    around do |example|
      Dir.mktmpdir('pact-dir') do |dir|
        @tmp_dir = dir
        example.run
      end
    end

    it 'raises when pact files exist but none match the configured provider' do
      write_pact('consumer-one', 'other-provider')

      expect do
        verifier.send(:ensure_provider_has_matching_pacts!, @tmp_dir)
      end.to raise_error(
        Pact::Provider::BaseVerifier::VerifierError,
        /No pacts found for provider "expected-provider"/
      )
    end

    it 'does not raise when at least one pact matches the configured provider' do
      write_pact('consumer-one', 'other-provider')
      write_pact('consumer-two', provider_name)

      expect do
        verifier.send(:ensure_provider_has_matching_pacts!, @tmp_dir)
      end.not_to raise_error
    end

    context 'when fail_if_no_pacts_found is false' do
      let(:fail_if_no_pacts_found) { false }

      it 'does not raise even when providers do not match' do
        write_pact('consumer-one', 'other-provider')

        expect do
          verifier.send(:ensure_provider_has_matching_pacts!, @tmp_dir)
        end.not_to raise_error
      end
    end

    def write_pact(consumer, provider)
      file_name = "#{consumer}-#{provider}.json"
      pact = {
        'consumer' => { 'name' => consumer },
        'provider' => { 'name' => provider },
        'interactions' => [],
        'metadata' => { 'pactSpecification' => { 'version' => '4.0' } }
      }

      File.write(File.join(@tmp_dir, file_name), JSON.dump(pact))
    end
  end
end
