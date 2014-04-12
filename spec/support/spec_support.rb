module Pact
  module SpecSupport
    def remove_ansicolor string
      string.gsub(/\e\[(\d+)m/, '')
    end
  end
end