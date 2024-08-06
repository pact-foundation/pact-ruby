require 'pact/provider/generator/datetime'

describe Pact::Provider::Generator::DateTime do
  generator = Pact::Provider::Generator::DateTime.new

  it 'can_generate with a supported hash' do
    hash = { 'type' => 'DateTime' }
    expect(generator.can_generate?(hash)).to be true
  end

  it 'can_generate with a unsupported hash' do
    hash = { 'type' => 'unknown' }
    expect(generator.can_generate?(hash)).to be false
  end

  it 'call' do
    hash = { 'type' => 'DateTime' }
    p generator.call(hash)
    expect(generator.call(hash).length).to eq(16)
  end
end
