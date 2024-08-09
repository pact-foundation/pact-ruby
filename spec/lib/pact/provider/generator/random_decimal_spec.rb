require 'pact/provider/generator/random_decimal'

describe Pact::Provider::Generator::RandomDecimal do
  generator = Pact::Provider::Generator::RandomDecimal.new

  it 'can_generate with a supported hash' do
    hash = { 'type' => 'RandomDecimal' }
    expect(generator.can_generate?(hash)).to be true
  end

  it 'can_generate with a unsupported hash' do
    hash = { 'type' => 'unknown' }
    expect(generator.can_generate?(hash)).to be false
  end

  it 'call' do
    hash = { 'type' => 'RandomDecimal' }
    value = generator.call(hash)
    expect(String(value).length).to eq 7
  end

  it 'call with digits' do
    hash = { 'type' => 'RandomDecimal', 'digits' => 10 }
    value = generator.call(hash)
    expect(String(value).length).to eq 11
  end
end
