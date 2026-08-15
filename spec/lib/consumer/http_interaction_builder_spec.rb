# frozen_string_literal: true

RSpec.describe Pact::Consumer::HttpInteractionBuilder do
  let(:pact_config) do
    instance_double(
      'Pact::ConsumerContractBuilder',
      pact_handle: nil,
      'pact_handle=' => nil,
      consumer_name: 'consumer',
      provider_name: 'provider',
      pact_specification: 'V4',
      log_level: 'INFO'
    )
  end

  subject { described_class.new(pact_config) }

  describe '#reference' do
    it 'queues the reference and returns self' do
      result = subject.reference('group', 'name', 'value')
      expect(subject.instance_variable_get(:@references)).to eq([%w[group name value]])
      expect(result).to be(subject)
    end

    it 'raises when group is blank' do
      expect do
        subject.reference('', 'name', 'value')
      end.to raise_error(described_class::InteractionBuilderError, /group is required/)
    end

    it 'raises when name is blank' do
      expect do
        subject.reference('group', '', 'value')
      end.to raise_error(described_class::InteractionBuilderError, /name is required/)
    end

    it 'raises when value is blank' do
      expect do
        subject.reference('group', 'name', '')
      end.to raise_error(described_class::InteractionBuilderError, /value is required/)
    end
  end
end
