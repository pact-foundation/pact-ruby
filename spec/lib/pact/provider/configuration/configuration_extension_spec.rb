require 'spec_helper'
require 'pact/provider/configuration/configuration_extension'

module Pact

  module Provider

    module Configuration

      describe ConfigurationExtension do

        subject { Object.new.extend(ConfigurationExtension) }

      end
    end
  end
end
