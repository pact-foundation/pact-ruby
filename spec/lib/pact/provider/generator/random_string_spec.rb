require 'pact/provider/generator/random_string'

describe Pact::Provider::Generator::RandomString do
  generator = Pact::Provider::Generator::RandomString.new

  it 'can_generate with a supported hash' do
    hash = { 'type' => 'RandomString' }
    expect(generator.can_generate?(hash)).to be true
  end

  it 'can_generate with a unsupported hash' do
    hash = { 'type' => 'unknown' }
    expect(generator.can_generate?(hash)).to be false
  end

  it 'call' do
    hash = { 'type' => 'RandomString' }
    expect(generator.call(hash).length).to eq(20)
  end

  it 'call with size' do
    hash = { 'type' => 'RandomString', 'size' => 30 }
    expect(generator.call(hash).length).to eq(30)
  end
end
