# frozen_string_literal: true

RSpec.describe Pact::Consumer::PluginSyncMessageInteractionBuilder do
  subject { described_class.new(nil) }

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
