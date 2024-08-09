require 'pact/provider/generator/random_int'

describe Pact::Provider::Generator::RandomInt do
  generator = Pact::Provider::Generator::RandomInt.new

  it 'can_generate with a supported hash' do
    hash = { 'type' => 'RandomInt' }
    expect(generator.can_generate?(hash)).to be true
  end

  it 'can_generate with a unsupported hash' do
    hash = { 'type' => 'unknown' }
    expect(generator.can_generate?(hash)).to be false
  end

  it 'call' do
    hash = { 'type' => 'RandomInt' }
    expect(generator.call(hash).instance_of?(Integer)).to be true
  end

  it 'call with min/max' do
    hash = { 'type' => 'RandomInt', 'min' => 5, 'max' => 5 }
    expect(generator.call(hash)).to eq 5
  end
end
