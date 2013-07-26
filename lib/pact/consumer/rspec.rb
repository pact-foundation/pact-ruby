require_relative '../configuration'
require_relative 'app_manager'

module Pact
  module Consumer
    module RSpec

      def consumer(name)
        FileUtils.mkdir_p Pact.configuration.pact_dir
        MockProducer.new(Pact.configuration.pact_dir).consumer(name)
      end

    end
  end
end

RSpec.configure do |config|
  config.include Pact::Consumer::RSpec, :pact => true

  config.before :each, :pact => true do
    Pact::Consumer::AppManager.instance.ports_of_registered_apps.each do | port |
      #Clear expectations
      Net::HTTP.new("localhost", port).delete("/interactions")
    end
  end

  config.after :all, :pact => true do
    Pact::Consumer::AppManager.instance.kill_all
    Pact::Consumer::AppManager.instance.clear_all
  end
end
