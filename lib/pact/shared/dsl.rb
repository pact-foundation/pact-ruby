require 'delegate'

module Pact

  class DslDelegator < SimpleDelegator
    def instance_eval_with_previous_context_available(*args, &b)
      meth = self.class.class_eval do
        define_method :cloaker_, &b
        meth = instance_method :cloaker_
        remove_method :cloaker_
        meth
      end
      with_previous_context(b.binding) {meth.bind(self).call(*args)}
    end

    def with_previous_context(binding, &block)
      @previous_context = binding.eval('self')
      result = block.call
      @previous_context = nil
      result
    end

    def method_missing(method, *args, &block)
      if __getobj__().respond_to? method
        super
      elsif @previous_context
        @previous_context.send(method, *args, &block)
      else
        super
      end
    end
  end


  # Ripped from http://blog.joecorcoran.co.uk/2013/09/04/simple-pattern-ruby-dsl
  # and then fixed up by using http://www.skorks.com/2013/03/a-closure-is-not-always-a-closure-in-ruby/
  # to access variables and methods defined in the calling scope.
  module DSL
    def build(*args, &block)
      base = self.new(*args)
      delegator_klass = self.const_get('DSL_DELEGATOR')
      delegator = delegator_klass.new(base)
      delegator.instance_eval_with_previous_context_available(&block)
      base.finalize
      base
    end

    def dsl(&block)
      delegator_klass = Class.new(DslDelegator, &block)
      self.const_set('DSL_DELEGATOR', delegator_klass)
    end
  end
end