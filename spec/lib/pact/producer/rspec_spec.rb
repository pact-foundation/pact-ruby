require 'pact/producer/rspec'

describe "the match_term matcher" do

  it 'does not match a hash to an array' do
    expect({}).to_not match_term([])
  end

  it 'does not match an array to a hash' do
    expect([]).to_not match_term({})
  end

  it 'matches regular expressions' do
    expect('blah').to match_term(/[a-z]*/)
  end

  it 'matches pact terms' do
    expect('wootle').to match_term Pact::Term.new(generate:'wootle', matcher:/woot../)
  end

  it 'matches all elements of arrays' do
    expect(['one', 'two', ['three']]).to match_term [/one/, 'two', [Pact::Term.new(generate:'three', matcher:/thr../)]]
  end

  it 'matches all values of hashes' do
    expect({1 => 'one', 2 => 2, 3 => 'three'}).to match_term({1 => /one/, 2 => 2, 3 => Pact::Term.new(generate:'three', matcher:/thr../)})
  end

  it 'matches all other objects using ==' do
    expect('wootle').to match_term 'wootle'
  end

  # Note: because a consumer specifies only the keys it cares about, the pact ignores keys that are returned
  # by the producer, but not are not specified in the pact. This means that any hash will match an
  # expected empty hash, because there is currently no way for a consumer to expect an absence of keys.
  it 'is confused by an empty hash' do
    expect({:hello => 'everyone'}).to match_term({})
  end

  it 'should not be confused by an empty array' do
    expect(['blah']).to_not match_term([])
  end

  it "should allow matches on an array where each item in the array only contains a subset of the actual" do
    expect([{name: 'Fred', age: 12}, {name: 'John', age: 13}]).to match_term([{name: 'Fred'}, {name: 'John'}])
  end

end
