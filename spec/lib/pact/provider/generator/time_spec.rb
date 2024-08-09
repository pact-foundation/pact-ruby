require 'pact/provider/generator/time'

describe Pact::Provider::Generator::Time do
  generator = Pact::Provider::Generator::Time.new

  it 'can_generate with a supported hash' do
    hash = { 'type' => 'Time' }
    expect(generator.can_generate?(hash)).to be true
  end

  it 'can_generate with a unsupported hash' do
    hash = { 'type' => 'unknown' }
    expect(generator.can_generate?(hash)).to be false
  end

  it 'call' do
    hash = { 'type' => 'Time' }
    expect(generator.call(hash).length).to eq(5)
  end
end
