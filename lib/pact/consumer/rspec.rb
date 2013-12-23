require 'pact/consumer'
require 'pact/consumer/spec_hooks'

module Pact
  module Consumer
    module RSpec
      include Pact::Consumer::ConsumerContractBuilders
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
    example_description = "#{example.example.example_group.description} #{example.example.description}"
    hooks.before_each example_description
  end

  config.after :each, :pact => true do | example |
    example_description = "#{example.example.example_group.description} #{example.example.description}"
    hooks.after_each example_description
  end

  config.after :suite do
    hooks.after_suite
  end
end
