module Pact
  module SpecSupport

    extend self

    def remove_ansicolor string
      string.gsub(/\e\[(\d+)m/, '')
    end
  end
end