require 'pact/provider/generator/provider_state'

describe Pact::Provider::Generator::ProviderState do
  generator = Pact::Provider::Generator::ProviderState.new

  it 'can_generate with a supported hash' do
    hash = { 'type' => 'ProviderState' }
    expect(generator.can_generate?(hash)).to be true
  end

  it 'can_generate with a unsupported hash' do
    hash = { 'type' => 'unknown' }
    expect(generator.can_generate?(hash)).to be false
  end

  it 'call without params' do
    hash = { 'type' => 'ProviderState', 'expression' => 'Bearer ${access_token}' }
    expect(generator.call(hash)).to eq 'Bearer '
  end

  it 'call with correct params' do
    hash = { 'type' => 'ProviderState', 'expression' => 'Bearer ${access_token}' }
    params = { 'access_token' => 'ABC' }
    expect(generator.call(hash, params)).to eq 'Bearer ABC'
  end

  it 'call with wrong params' do
    hash = { 'type' => 'ProviderState', 'expression' => 'Bearer ${access_token}' }
    params = { 'refresh_token' => 'ABC' }
    expect(generator.call(hash, params)).to eq 'Bearer '
  end

  it 'call with incomplete expression' do
    hash = { 'type' => 'ProviderState', 'expression' => 'Bearer ${access_token' }
    expect { generator.call(hash) }.to raise_error('Missing closing brace in expression string')
  end
end
