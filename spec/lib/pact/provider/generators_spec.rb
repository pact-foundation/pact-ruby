require 'pact/provider/generators'
require 'pact/provider/request'

describe Pact::Provider::Generators do
  it 'execute_generators with Boolean' do
    hash = { 'type' => 'Boolean' }
    expect(Pact::Provider::Generators.execute_generators(hash)).to eq(true).or eq(false)
  end

  it 'execute_generators with Date' do
    hash = { 'type' => 'Date' }
    expect(Pact::Provider::Generators.execute_generators(hash).length).to eq(10)
  end

  it 'execute_generators with DateTime' do
    hash = { 'type' => 'DateTime' }
    expect(Pact::Provider::Generators.execute_generators(hash).length).to eq(16)
  end

  it 'execute_generators with ProviderState' do
    hash = { 'type' => 'ProviderState', 'expression' => 'Bearer ${access_token}' }
    params = { 'access_token' => 'ABC' }
    expect(Pact::Provider::Generators.execute_generators(hash, params)).to eq('Bearer ABC')
  end

  it 'execute_generators with RandomDecimal' do
    hash = { 'type' => 'RandomDecimal' }
    expect(String(Pact::Provider::Generators.execute_generators(hash)).length).to eq(7)
  end

  it 'execute_generators with RandomHexadecimal' do
    hash = { 'type' => 'RandomHexadecimal' }
    expect(Pact::Provider::Generators.execute_generators(hash).length).to eq(8)
  end

  it 'execute_generators with RandomInt' do
    hash = { 'type' => 'RandomInt' }
    expect(Pact::Provider::Generators.execute_generators(hash).instance_of?(Integer)).to be true
  end

  it 'execute_generators with RandomString' do
    hash = { 'type' => 'RandomString' }
    expect(Pact::Provider::Generators.execute_generators(hash).length).to eq(20)
  end

  it 'execute_generators with Regex' do
    hash = { 'type' => 'Regex', 'pattern' => '(one|two)' }
    expect(Pact::Provider::Generators.execute_generators(hash)).to eq('one').or eq('two')
  end

  it 'execute_generators with Time' do
    hash = { 'type' => 'Time' }
    expect(Pact::Provider::Generators.execute_generators(hash).length).to eq(5)
  end

  it 'execute_generators with Uuid' do
    hash = { 'type' => 'Uuid' }
    expect(Pact::Provider::Generators.execute_generators(hash).length).to eq(36)
  end

  it 'apply_generators for path' do
    expected_request = Pact::Request::Expected.from_hash({
      method: 'GET',
      path: '/path/1',
      generators: {
        'path' => {
          'type' => 'ProviderState',
          'expression' => '/path/${itemID}'
        }
      }
    })
    state_params = {
      'itemID' => 2
    }
    request = Pact::Provider::Request::Replayable.new(expected_request, state_params)
    expect(request.path).to eq('/path/2')
  end

  it 'apply_generators for headers' do
    expected_request = Pact::Request::Expected.from_hash({
      method: 'GET',
      path: '/path/1',
      headers: {
        'Authorization' => 'Bearer 123'
      },
      generators: {
        'header' => {
          '$.Authorization' => {
            'expression' => 'Bearer ${accessToken}',
            'type' => 'ProviderState'
          }
        }
      }
    })
    state_params = {
      'accessToken' => 'ABC'
    }
    request = Pact::Provider::Request::Replayable.new(expected_request, state_params)
    expect(request.headers).to eq({
      'HTTP_AUTHORIZATION' => 'Bearer ABC'
    })
  end

  it 'apply_generators for body' do
    expected_request = Pact::Request::Expected.from_hash({
      method: 'GET',
      path: '/path/1',
      body: {
        'result' => [
          '12345F'
        ]
      },
      generators: {
        'body' => {
          '$.result[0]' => {
            'type' => 'RandomHexadecimal'
          }
        }
      }
    })
    request = Pact::Provider::Request::Replayable.new(expected_request)
    expect(request.body['result'][0].length).to eq(8)
  end
end
