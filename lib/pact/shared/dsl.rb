module Pact

  class DslDelegator

    def initialize delegation_target
      @delegation_target = delegation_target
    end

    def instance_eval_with_previous_context_available(*args, &block)
      with_previous_context_available(block.binding) do
        bind_block_as_instance_method_on_self(&block).call(*args)
      end
    end

    protected

    def method_missing(method, *args, &block)
      if delegation_target_responds_to? method
        delegation_target.send(method, *args, &block)
      else
        previous_context.send(method, *args, &block)
      end
    end

    private

    attr_accessor :delegation_target, :previous_context

    def bind_block_as_instance_method_on_self(&block)
      create_instance_method_from_block(&block).bind(self)
    end


    def create_instance_method_from_block &block
      meth = self.class.class_eval do
        define_method :block_as_instance_method_, &block
        meth = instance_method :block_as_instance_method_
        remove_method :block_as_instance_method_
        meth
      end
    end

    def with_previous_context_available(binding, &block)
      @previous_context = binding.eval('self')
      result = block.call
      @previous_context = nil
      result
    end

    def delegation_target_responds_to?(method)
      delegation_target.respond_to? method
    end

  end


  # Ripped from http://blog.joecorcoran.co.uk/2013/09/04/simple-pattern-ruby-dsl
  # and then fixed up by using http://www.skorks.com/2013/03/a-closure-is-not-always-a-closure-in-ruby/
  # to access variables and methods defined in the calling scope.
  module DSL
    def build(*args, &block)
      new_instance_of_delegation_target_class = self.new(*args)
      dsl_delegator_class = self.const_get('DSL_DELEGATOR_CLASS')
      dsl_delegator = dsl_delegator_class.new(new_instance_of_delegation_target_class)
      dsl_delegator.instance_eval_with_previous_context_available(&block)
      new_instance_of_delegation_target_class.finalize
      new_instance_of_delegation_target_class
    end

    def dsl(&block)
      dsl_delegator_class = Class.new(DslDelegator, &block)
      self.const_set('DSL_DELEGATOR_CLASS', dsl_delegator_class)
    end

  end
end