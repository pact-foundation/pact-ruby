require 'delegate'

module Pact
  # Ripped from http://blog.joecorcoran.co.uk/2013/09/04/simple-pattern-ruby-dsl
  module DSL
    def build(*args, &block)
      base = self.new(*args)
      delegator_klass = self.const_get('DSLDelegator')
      delegator = delegator_klass.new(base)
      delegator.instance_eval(&block)
      base.finalize
      base
    end

    def dsl(&block)
      delegator_klass = Class.new(SimpleDelegator, &block)
      self.const_set('DSLDelegator', delegator_klass)
    end
  end
end