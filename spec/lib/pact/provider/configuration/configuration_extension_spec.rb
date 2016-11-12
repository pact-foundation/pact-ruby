require 'spec_helper'
require 'pact/provider/configuration/configuration_extension'

module Pact

  module Provider

    module Configuration

      describe ConfigurationExtension do

        subject { Object.new.extend(ConfigurationExtension) }

        it 'replays interactions in the recorded order by default' do
          expect(subject.interactions_replay_order).to eq :recorded
        end

      end
    end
  end
end
