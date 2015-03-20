describe Pact::Provider::PactRepositoryUri do
  let(:uri) { 'http://uri'}
  let(:username) { 'pact'}
  let(:options) { {username: username}}
  let(:pact_repository_uri) { Pact::Provider::PactRepositoryUri.new(uri, options)}
  describe '#==' do

    it 'should return false if object is not PactRepositoryUri' do
      expect(pact_repository_uri == Object.new).to be false
    end

    it 'should return false if uri is not equal' do
      expect(pact_repository_uri == Pact::Provider::PactRepositoryUri.new('other_uri', options)).to be false
    end

    it 'should return false if uri options are not equal' do
      expect(pact_repository_uri == Pact::Provider::PactRepositoryUri.new(uri, {username: 'wrong user'})).to be false
    end

    it 'should return true if uri and options are equal' do
      expect(pact_repository_uri == Pact::Provider::PactRepositoryUri.new(uri, options)).to be true
    end
  end
end