require 'pact/consumer'
require 'pact/consumer/spec_hooks'
require 'pact/rspec'
require 'pact/helpers'

module Pact
  module Consumer
    module RSpec
      include Pact::Consumer::ConsumerContractBuilders
      include Pact::Helpers
    end
  end
end

hooks = Pact::Consumer::SpecHooks.new

RSpec.configure do |config|
  config.include Pact::Consumer::RSpec, :pact => true

  config.before :all, :pact => true do
    hooks.before_all
  end

  config.before :each, :pact => true do | example |
    hooks.before_each Pact::RSpec.full_description(example)
  end

  config.after :each, :pact => true do | example |
    hooks.after_each Pact::RSpec.full_description(example)
  end

  config.after :suite do
    hooks.after_suite
  end
end
