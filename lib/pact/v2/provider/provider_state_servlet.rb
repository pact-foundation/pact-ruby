# frozen_string_literal: true

require "webrick"

module Pact
  module V2
    module Provider
      class ProviderStateServlet < WEBrick::HTTPServlet::ProcHandler
        attr_reader :logger

        def initialize(logger: nil)
          super(build_proc)

          @logger = logger || Logger.new($stdout)

          @provider_setup_states = {}
          @provider_teardown_states = {}

          @before_setup_hook_proc = nil
          @after_teardown_hook_proc = nil

          @global_setup_hook = ::Pact::V2.configuration.before_provider_state_proc
          @global_teardown_hook = ::Pact::V2.configuration.after_provider_state_proc
        end

        def add_setup_state(name, use_before_setup_hook, &block)
          raise "provider state #{name} already configured" if @provider_setup_states[name].present?

          @provider_setup_states[name] = {proc: block, use_hooks: use_before_setup_hook}
        end

        def add_teardown_state(name, use_after_teardown_hook, &block)
          raise "provider state #{name} already configured" if @provider_teardown_states[name].present?

          @provider_teardown_states[name] = {proc: block, use_hooks: use_after_teardown_hook}
        end

        def before_setup(&block)
          @before_setup_hook_proc = block
        end

        def after_teardown(&block)
          @after_teardown_hook_proc = block
        end

        private

        def call_setup(state_name, state_data)
          logger.debug "call_setup #{state_name} with #{state_data}"
          @global_setup_hook&.call
          @before_setup_hook_proc&.call(state_name, state_data) if @provider_setup_states.dig(state_name, :use_hooks)
          @provider_setup_states.dig(state_name, :proc)&.call(state_data)
        end

        def call_teardown(state_name, state_data)
          logger.debug "call_teardown #{state_name} with #{state_data}"
          @provider_teardown_states.dig(state_name, :proc)&.call(state_data)
          @after_teardown_hook_proc&.call(state_name, state_data) if @provider_setup_states.dig(state_name, :use_hooks)
          @global_teardown_hook&.call
        end

        def build_proc
          proc do |request, response|
            # {"action" => "setup", "params" => {"order_uuid" => "mxfcpcsfUOHO"},"state" => "order exists and can be saved"}
            # {"action"=> "teardown", "params" => {"order_uuid" => "mxfcpcsfUOHO"}, "state" => "order exists and can be saved"}
            data = JSON.parse(request.body)

            action = data["action"]
            state_name = data["state"]
            state_data = data["params"]

            logger.warn("unknown callback state action: #{action}") if action.blank?

            call_setup(state_name, state_data) if action == "setup"
            call_teardown(state_name, state_data) if action == "teardown"

            response.status = 200
          rescue JSON::ParserError => ex
            logger.error("cannot parse request: #{ex.message}")
            response.status = 500
          end
        end
      end
    end
  end
end
