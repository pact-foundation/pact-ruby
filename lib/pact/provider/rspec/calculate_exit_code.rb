module Pact
  module Provider
    module RSpec
      module CalculateExitCode
        def self.call(pact_sources, failed_examples)
          any_non_pending_failures = pact_sources.any? do |pact_source|
            if pact_source.pending?
              nil
            else
              failed_examples.select { |e| e.metadata[:pact_source] == pact_source }.any?
            end
          end
          any_non_pending_failures ? 1 : 0
        end
      end
    end
  end
end
