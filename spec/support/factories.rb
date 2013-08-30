require 'hashie'
require 'hashie/extensions/key_conversion'

class InteractionFactory

  class Options < Hash
    include Hashie::Extensions::StringifyKeys
    include Hashie::Extensions::DeepMerge
  end

  DEFAULTS = Options[
    'request' => {
      'path' => '/path',
      'method' => 'get',
    },
    'response' => {
      'status' => 200,
    },
    'description' => 'a description',
    'provider_state' => 'a thing exists'
  ]

  def self.create hash = {}
    Pact::Interaction.from_hash(DEFAULTS.deep_merge(Options[hash].stringify_keys))
  end
end