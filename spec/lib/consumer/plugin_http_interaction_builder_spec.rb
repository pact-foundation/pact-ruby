# frozen_string_literal: true

RSpec.describe Pact::Consumer::PluginHttpInteractionBuilder do
  subject { described_class.new(nil) }

  describe '#reference' do
    it 'queues the reference and returns self' do
      result = subject.reference('group', 'name', 'value')
      expect(subject.instance_variable_get(:@references)).to eq([['group', 'name', 'value']])
      expect(result).to be(subject)
    end

    it 'raises when group is blank' do
      expect { subject.reference('', 'name', 'value') }.to raise_error(described_class::InteractionBuilderError, /group is required/)
    end

    it 'raises when name is blank' do
      expect { subject.reference('group', '', 'value') }.to raise_error(described_class::InteractionBuilderError, /name is required/)
    end

    it 'raises when value is blank' do
      expect { subject.reference('group', 'name', '') }.to raise_error(described_class::InteractionBuilderError, /value is required/)
    end
  end
end
