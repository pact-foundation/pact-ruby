require 'pact/provider/generator/boolean'

describe Pact::Provider::Generator::Boolean do
  generator = Pact::Provider::Generator::Boolean.new

  it 'can_generate with a supported hash' do
    hash = { 'type' => 'Boolean' }
    expect(generator.can_generate?(hash)).to be true
  end

  it 'can_generate with a unsupported hash' do
    hash = { 'type' => 'unknown' }
    expect(generator.can_generate?(hash)).to be false
  end

  it 'call' do
    hash = { 'type' => 'Boolean' }
    expect(generator.call(hash)).to eq(true).or eq(false)
  end
end
