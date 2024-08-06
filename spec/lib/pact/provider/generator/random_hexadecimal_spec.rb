require 'pact/provider/generator/random_hexadecimal'

describe Pact::Provider::Generator::RandomHexadecimal do
  generator = Pact::Provider::Generator::RandomHexadecimal.new

  it 'can_generate with a supported hash' do
    hash = { 'type' => 'RandomHexadecimal' }
    expect(generator.can_generate?(hash)).to be true
  end

  it 'can_generate with a unsupported hash' do
    hash = { 'type' => 'unknown' }
    expect(generator.can_generate?(hash)).to be false
  end

  it 'call' do
    hash = { 'type' => 'RandomHexadecimal' }
    expect(generator.call(hash).length).to eq(8)
  end

  it 'call with size' do
    hash = { 'type' => 'RandomHexadecimal', 'digits' => 2 }
    expect(generator.call(hash).length).to eq(2)
  end
end
