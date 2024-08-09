require 'pact/provider/generator/uuid'

describe Pact::Provider::Generator::Uuid do
  generator = Pact::Provider::Generator::Uuid.new

  it 'can_generate with a supported hash' do
    hash = { 'type' => 'Uuid' }
    expect(generator.can_generate?(hash)).to be true
  end

  it 'can_generate with a unsupported hash' do
    hash = { 'type' => 'unknown' }
    expect(generator.can_generate?(hash)).to be false
  end

  it 'call' do
    hash = { 'type' => 'Uuid' }
    expect(generator.call(hash).length).to eq(36)
  end
end
