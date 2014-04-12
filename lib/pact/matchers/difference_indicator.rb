require 'pact/shared/active_support_support'

module Pact
  class DifferenceIndicator

    include ActiveSupportSupport

    def == other
      other.class == self.class
    end

    def eql? other
      self == other
    end

    def to_json options = {}
      remove_unicode as_json.to_json(options)
    end

    def as_json options = {}
      to_s
    end

  end

end