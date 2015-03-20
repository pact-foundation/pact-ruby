describe Pact::Provider::PactURI do
  let(:uri) { 'http://uri'}
  let(:username) { 'pact'}
  let(:options) { {username: username}}
  let(:pact_uri) { Pact::Provider::PactURI.new(uri, options)}
  describe '#==' do

    it 'should return false if object is not PactURI' do
      expect(pact_uri == Object.new).to be false
    end

    it 'should return false if uri is not equal' do
      expect(pact_uri == Pact::Provider::PactURI.new('other_uri', options)).to be false
    end

    it 'should return false if uri options are not equal' do
      expect(pact_uri == Pact::Provider::PactURI.new(uri, {username: 'wrong user'})).to be false
    end

    it 'should return true if uri and options are equal' do
      expect(pact_uri == Pact::Provider::PactURI.new(uri, options)).to be true
    end
  end
end