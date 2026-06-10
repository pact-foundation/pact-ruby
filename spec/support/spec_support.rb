require 'pact/support/rspec'

module Pact
  module SpecSupport
    extend self

    def remove_ansicolor(string)
      string.gsub(/\e\[(\d+)m/, '')
    end

    Pact::Support::RSpec.with_rspec_2 do
      def instance_double(*args)
        double(*args)
      end
    end
  end
end