require 'pact/provider/generator/date'

describe Pact::Provider::Generator::Date do
  generator = Pact::Provider::Generator::Date.new

  it 'can_generate with a supported hash' do
    hash = { 'type' => 'Date' }
    expect(generator.can_generate?(hash)).to be true
  end

  it 'can_generate with a unsupported hash' do
    hash = { 'type' => 'unknown' }
    expect(generator.can_generate?(hash)).to be false
  end

  it 'call' do
    hash = { 'type' => 'Date' }
    expect(generator.call(hash).length).to eq(10)
  end
end
