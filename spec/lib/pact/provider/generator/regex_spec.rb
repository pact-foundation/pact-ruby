require 'pact/provider/generator/regex'

describe Pact::Provider::Generator::Regex do
  generator = Pact::Provider::Generator::Regex.new

  it 'can_generate with a supported hash' do
    hash = { 'type' => 'Regex' }
    expect(generator.can_generate?(hash)).to be true
  end

  it 'can_generate with a unsupported hash' do
    hash = { 'type' => 'unknown' }
    expect(generator.can_generate?(hash)).to be false
  end

  it 'call' do
    hash = { 'type' => 'Regex', 'pattern' => '(one|two)' }
    expect(generator.call(hash)).to eq('one').or eq('two')
  end
end
