require 'pact/provider/rspec/matchers'
require 'pact/shared/json_differ'
require 'pact/matchers/unix_diff_formatter'

describe "the match_term matcher" do

  include Pact::RSpec::Matchers

  let(:diff_formatter) { Pact::Matchers::UnixDiffFormatter }

  it 'does not match a hash to an array' do  | example |
    expect({})
      .to_not match_term([], { with: Pact::JsonDiffer, diff_formatter: diff_formatter }, example)
  end

  it 'does not match an array to a hash' do  | example |
    expect([])
      .to_not match_term({}, { with: Pact::JsonDiffer, diff_formatter: diff_formatter }, example)
  end

  it 'matches regular expressions' do  | example |
    expect('blah')
      .to match_term(/[a-z]*/, { with: Pact::JsonDiffer, diff_formatter: diff_formatter }, example)
  end

  it 'matches pact terms' do  | example |
    expect('wootle')
      .to match_term Pact.term(generate: 'wootle', matcher: /woot../), { with: Pact::JsonDiffer, diff_formatter: diff_formatter }, example
  end

  it 'matches all elements of arrays' do  | example |
    expect(['one', 'two', ['three']])
      .to match_term [/one/, 'two', [Pact.term(generate: 'three', matcher: /thr../)]], { with: Pact::JsonDiffer, diff_formatter: diff_formatter }, example
  end

  it 'matches all values of hashes' do  | example |
    expect({ 1 => 'one', 2 => 2, 3 => 'three' })
      .to match_term({ 1 => /one/, 2 => 2, 3 => Pact.term(generate: 'three', matcher: /thr../) }, { with: Pact::JsonDiffer, diff_formatter: diff_formatter }, example)
  end

  it 'matches all other objects using ==' do  | example |
    expect('wootle').to match_term 'wootle', { with: Pact::JsonDiffer, diff_formatter: diff_formatter }, example
  end

  # Note: because a consumer specifies only the keys it cares about, the pact ignores keys that are returned
  # by the provider, but not are not specified in the pact. This means that any hash will match an
  # expected empty hash, because there is currently no way for a consumer to expect an absence of keys.
  it 'is confused by an empty hash' do  | example |
    expect(hello: 'everyone').to match_term({}, { with: Pact::JsonDiffer, diff_formatter: diff_formatter }, example)
  end

  it 'should not be confused by an empty array' do  | example |
    expect(['blah']).to_not match_term([], { with: Pact::JsonDiffer, diff_formatter: diff_formatter }, example)
  end

  it "should allow matches on an array where each item in the array only contains a subset of the actual" do  | example |
    expect([{ name: 'Fred', age: 12 }, { name: 'John', age: 13 }])
      .to match_term([{ name: 'Fred' }, { name: 'John' }], { with: Pact::JsonDiffer, diff_formatter: diff_formatter }, example)
  end
end
